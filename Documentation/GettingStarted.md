# Getting Started

> From zero to a running feature on Pal. Read [Architecture](ARCHITECTURE.md) for the *why*; this is the *how*.

## Requirements

- **iOS 17+** deployment target · **Swift 6** (strict concurrency) · Xcode 16+.
- Pal has **zero external dependencies**. Swinject (if you use it) is an app-side choice, never pulled in by Pal.

## 1. Add the package

In Xcode: **File ▸ Add Package Dependencies…**, enter the repository URL, and pin to a version (or `main` for early apps). Or in your own `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Mesrine23/pal-mvvm-foundation.git", from: "0.12.0"),
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "PalCore", package: "pal-mvvm-foundation"),
        .product(name: "PalNetworking", package: "pal-mvvm-foundation"),
        .product(name: "PalPresentation", package: "pal-mvvm-foundation"),
        .product(name: "PalNavigation", package: "pal-mvvm-foundation"),
        // …add only the products you need
    ]),
]
```

Import only what you use. Each product declares its own dependencies (the [DAG](ARCHITECTURE.md#package-map)); you never get more than you ask for.

> **Multi-target apps:** a Pal product linked to the *app* target is not visible to separate framework targets. Each framework that imports a Pal product must link it directly (e.g. your Data framework links `PalNetworking`). Domain links nothing — it stays pure Swift.

## 2. The app shell (the ~15% a package can't ship)

A package can't provide `@main`, the root scene, `Info.plist`, entitlements, or your composition root. You write those once:

```swift
import SwiftUI

@main
struct MyApp: App {
    @State private var container = AppContainer()
    var body: some Scene {
        WindowGroup { RootView(container: container) }
    }
}
```

## 3. The composition root

Wire dependencies in one place. Manual constructor injection needs no DI framework:

```swift
import PalNetworking

@MainActor
final class AppContainer {
    private let client: NetworkClient = HTTPClient(baseURL: AppConfig.baseURL)
    private lazy var usersRepo: UsersRepoProtocol = UsersRepository(client: client)

    func makeUsersListViewModel(delegate: UsersListNavigationDelegate?) -> UsersListViewModel {
        UsersListViewModel(fetchUsers: FetchUsersUseCase(usersRepo: usersRepo), delegate: delegate)
    }
    // one factory method per feature; grows as the app grows
}
```

Larger apps can use Swinject (native `Assembly`/`Assembler`, single root container) instead — see [Architecture](ARCHITECTURE.md). Either way: **factories resolve dependencies and constructor-inject ViewModels.**

## 4. Your first feature (the canonical vertical slice)

Every feature follows the same shape. Build it once and the pattern repeats.

**Domain — pure Swift (no networking, no UI):**

```swift
struct User: Sendable, Identifiable, Equatable { let id: Int; let name: String }

protocol UsersRepoProtocol: Sendable { func getUsers() async throws -> [User] }

protocol FetchUsersUseCaseProtocol: Sendable { func execute() async throws -> [User] }
struct FetchUsersUseCase: FetchUsersUseCaseProtocol {
    let usersRepo: UsersRepoProtocol
    func execute() async throws -> [User] { try await usersRepo.getUsers() }
}
```

**Data — DTO + request factory + repository (maps DTO → entity):**

```swift
import PalNetworking

struct UserDTO: Decodable, Sendable {
    let id: Int; let full_name: String
    var toDomain: User { User(id: id, name: full_name) }
}
extension Request { static func users() -> Request<[UserDTO]> { .init(path: "/users") } }

struct UsersRepository: UsersRepoProtocol {
    let client: NetworkClient
    func getUsers() async throws -> [User] { try await client.send(.users()).map(\.toDomain) }
}
```

**Presentation — ViewModel holds a `Loader`; View switches on its state:**

```swift
import PalPresentation

@MainActor @Observable
final class UsersListViewModel {
    let users = Loader<[User]>()
    private let fetchUsers: FetchUsersUseCaseProtocol
    private weak var delegate: UsersListNavigationDelegate?

    init(fetchUsers: FetchUsersUseCaseProtocol, delegate: UsersListNavigationDelegate?) {
        self.fetchUsers = fetchUsers; self.delegate = delegate
    }
    func refresh() { users.load { try await self.fetchUsers.execute() } }
    func userTapped(_ user: User) { delegate?.showUserDetail(user) }
}
```

```swift
import SwiftUI
import PalPresentation
import PalDesignSystem

struct UsersListView: View {
    @State var viewModel: UsersListViewModel
    var body: some View {
        Group {
            switch viewModel.users.state {
            case .idle, .loading(previous: nil):    LoadingView()
            case .loading(previous: let users?):    list(users).overlay { ProgressView() }
            case .loaded(let users):                list(users)
            case .failed(let error, previous: nil): ErrorView(error) { viewModel.refresh() }
            case .failed(_, previous: let users?):  list(users)   // + banner over stale data
            }
        }
        .task { await viewModel.users.performLoad { try await viewModel.refresh() } }
    }
    func list(_ users: [User]) -> some View {
        List(users) { user in Button(user.name) { viewModel.userTapped(user) } }
    }
}
```

That's the whole loop: **View → ViewModel → UseCase → Repository → NetworkClient**, dependencies pointing inward to Domain.

## 5. Navigation

Define a typed route, render with `RouterView`, and let the ViewModel delegate intents (see [PalNavigation](Products/PalNavigation.md)):

```swift
import PalNavigation

enum UsersRoute: Routable { case detail(User) }

RouterView(router: router) { route in
    switch route { case .detail(let user): UserDetailView(/* … */) }
}
```

## 6. Optional wiring

- **Auth refresh** — supply a `TokenRefreshService`, use `KeychainTokenStore` ([PalAuth](Products/PalAuth.md)), build a `TokenProvider`, add `AuthInterceptor`. See [PalNetworking](Products/PalNetworking.md).
- **Analytics / flags** — register `NoOp…` by default; swap to real providers at the composition root. See [PalAnalytics](Products/PalAnalytics.md) / [PalFeatureFlags](Products/PalFeatureFlags.md).
- **Theming** — works with `Theme.system` out of the box; brand with `.theme(myTheme)`. See [PalDesignSystem](Products/PalDesignSystem.md).
- **Debug tools** — `PalDebugKit` (network logs, env switcher, mocks) is the one product still landing. See [PalDebugKit](Products/PalDebugKit.md).

## Editing Pal while building your app

Pin to the Git URL by default. To change Pal mid-app-work: clone it locally, drag the folder into your app's workspace (the local copy overrides the remote pin), edit live, then commit/push/tag Pal, remove the override, and bump your pin.

## Where to go next

- [Architecture](ARCHITECTURE.md) — layers, the DAG, patterns, adoption notes.
- [Per-product guides](Products/) — the full API of each product.
- [Design decisions](DECISIONS.md) — why Pal is shaped the way it is (open to discussion).
