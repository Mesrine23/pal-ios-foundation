# Pal — Architecture

> How the foundation is structured and how apps build on it. Decisions and their rationale live in [DECISIONS.md](DECISIONS.md) — this document explains shape and patterns.

## Layers

```
┌─────────────────────────────────────────────────────────┐
│ Presentation   View (SwiftUI) → ViewModel (@Observable) │  imports Domain only
├─────────────────────────────────────────────────────────┤
│ Domain         Entities · Repo protocols · Use cases    │  pure Swift, imports nothing
├─────────────────────────────────────────────────────────┤
│ Data           DTOs · Request factories · Repositories  │  imports Domain + PalNetworking
└─────────────────────────────────────────────────────────┘
        all dependency arrows point inward to Domain
```

- The network decodes **DTOs**; the repository maps DTO → entity. Domain never sees `Decodable` or HTTP.
- ViewModels receive use cases via `init` (constructor injection). Views never touch clients or repositories.

## Package map

```
PalCore ──────────────┐
   ▲                  │ (no SwiftUI in Core)
   │                  │
PalPersistence   PalNetworking   PalPresentation   PalNavigation
        ▲             ▲               ▲                (no deps)
        └── PalAuth ──┘               │
                                PalDesignSystem
PalAnalytics · PalFeatureFlags (→ Core)
PalDebugKit (→ Core, Networking, Persistence)
```

| Product | Role |
|---|---|
| `PalCore` | LoggerFactory (os.Logger), curated Foundation extensions, Debouncer/withTimeout, AppInfo, AppLanguage |
| `PalPersistence` | KeychainService (throwing), UserDefaultsService, typed keys (`KeychainKey`/`DefaultsKey`), MemoryCache (actor, passive TTL, memory-only) |
| `PalNetworking` | `Request<Response>`, `HTTPClient` (typed `throws(NetworkError)`), interceptor onion over `TransportRequest`, `TokenProvider` single-flight refresh actor |
| `PalAuth` | `KeychainTokenStore` glue (TokenStore ⇄ KeychainService) |
| `PalPresentation` | `ViewState<Value>`, `PresentableError`, `LoadableViewModelProtocol` + runner |
| `PalNavigation` | `Routable`, `Router<Route>`, `RouterView`, deep-link strategies, Identifiable modal items |
| `PalDesignSystem` | Opt-in Theme (system default), `.textStyle`, ErrorView/SectionErrorView/EmptyStateView/LoadingView, `.appAlert`, SwiftUI utilities, en+el catalogs |
| `PalAnalytics` / `PalFeatureFlags` | Provider-agnostic seams + NoOp/Console/Composite/InMemory impls |
| `PalDebugKit` | Shake debug menu (overlay window): network Logs, API environment switcher, Mocks — runtime-enabled, gated app-side by the `DEBUGKIT` flag |

## The canonical vertical slice

```swift
// DOMAIN — pure
public struct User: Sendable, Identifiable, Equatable { public let id: Int; public let name: String }

public protocol UsersRepoProtocol: Sendable {
    func getUsers() async throws -> [User]
}

public protocol FetchUsersUseCaseProtocol: Sendable {
    func execute() async throws -> [User]
}
public struct FetchUsersUseCase: FetchUsersUseCaseProtocol {
    private let usersRepo: UsersRepoProtocol
    public init(usersRepo: UsersRepoProtocol) { self.usersRepo = usersRepo }
    public func execute() async throws -> [User] { try await usersRepo.getUsers() }
}

// DATA — DTO + request factory + repository
struct UserDTO: Decodable, Sendable {
    let id: Int
    let full_name: String
    func toDomain() -> User { User(id: id, name: full_name) }
}
extension Request {
    static func users() -> Request<[UserDTO]> { .init(path: "/users") }
}
struct UsersRepository: UsersRepoProtocol {
    let client: NetworkClient
    func getUsers() async throws -> [User] { try await client.send(.users()).map { $0.toDomain() } }
}

// PRESENTATION — ViewModel + View
@MainActor protocol UsersListNavigationDelegate: AnyObject {
    func showUserDetail(_ user: User)
}

@MainActor @Observable
final class UsersListViewModel: LoadableViewModelProtocol {
    private(set) var state: ViewState<[User]> = .idle
    var loadTask: Task<Void, Never>?
    private let fetchUsers: FetchUsersUseCaseProtocol
    private weak var delegate: UsersListNavigationDelegate?

    init(fetchUsers: FetchUsersUseCaseProtocol, delegate: UsersListNavigationDelegate?) {
        self.fetchUsers = fetchUsers
        self.delegate = delegate
    }

    func refresh() { load { try await self.fetchUsers.execute() } }
    func userTapped(_ user: User) { delegate?.showUserDetail(user) }
}

// COMPOSITION ROOT (app shell, @MainActor; Swinject demonstrated in Example/)
// factory resolves use cases and constructor-injects the VM; factories are the
// only code that touches the container; resolve(...)! is the sanctioned fail-fast.
```

## Key patterns

**Multi-call screens** — a composing use case returns a composite model; `async let` for independent calls, plain `await` where data-dependent; one `load {}` in the VM.

**Partial failure** — optional topics typed `Result<Value, PresentableError>` inside the composite; View renders content or `SectionErrorView` per topic; critical call still throws.

**Failure channels** — LOAD failures drive `ViewState.failed` (full error screen or banner over stale data); ACTION failures (screen keeps its data) drive `.appAlert`.

**Modals (hybrid)** — screen-local UI modals (pickers/filters; need Bindings into the presenting VM) stay view-level; multi-screen flow modals (checkout/onboarding/auth-expired) go through `router.present(_:)` with a nested `RouterView`. Presentations are Identifiable items, never booleans.

**Deep links** — `DeepLinkHandler` maps URL → routes + strategy; `.append` protects in-progress user state, `.replace` resets. The push-launch flow is just "set the path".

**Caching** — repository-level cache-aside via `MemoryCache` (`forceRefresh:` bypass, per-key TTL, passive expiry, `clear()` on logout). Never HTTP-level.

**Auth refresh** — `AuthInterceptor` injects the Bearer token and, on 401, awaits `TokenProvider.refresh()` (single-flight actor: N concurrent 401s → one refresh) and retries once. `AuthEvent.loggedOut` streams to the root coordinator → present login flow.

**DebugKit gating** — package code always compiles; activation is runtime + default-OFF. Apps define the `DEBUGKIT` compilation condition in the configurations that should carry tools and wrap `PalDebugTools.enable(…)` + Inspector/Mock wiring in `#if DEBUGKIT` at the composition root. SPM builds packages in release mode for any non-"Debug" app configuration — the package can never self-gate per configuration; this is why the flag lives in the app.

## Workflows

- **Live-edit Pal while building an app:** drag the local Pal checkout into the app's workspace (local override beats the remote pin) → edit live → commit/push/tag → remove override → bump the app's pin.
- **Phases:** implementation proceeds per DECISIONS.md §21; every phase ends with `swift build` + `swift test` green and the Example app compiling.
