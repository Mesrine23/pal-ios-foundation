# PalNavigation

> Typed, payload-carrying routes over `NavigationStack`, with a `Router` ViewModels delegate to, nested-stack modals, and deep links. Zero `AnyView`, no view caching, no DI types. Dependencies: none.

`import PalNavigation`

## What it gives you

- **`Routable`** — your route enum (`Hashable & Sendable`) with **payloads in the cases**.
- **`Router<Route>`** — `@MainActor @Observable`; a typed `[Route]` path plus modal presentation.
- **`RouterView<Route, Destination>`** — wraps `NavigationStack` + `navigationDestination` + modal bindings.
- **Deep links** — `DeepLinkHandler` → `DeepLinkResult { routes, strategy }`.

## Define routes with payloads

```swift
import PalNavigation

enum UsersRoute: Routable {
    case detail(User)        // payload rides the route — no "courier" registration
    case settings
}
```

## Router API

```swift
let router = Router<UsersRoute>()

router.push(.detail(user))
router.pop()                       // pop(_ count: Int = 1)
router.pop(to: .settings)
router.popToRoot()
router.replace(with: [.settings])
router.navigate(to: [.detail(a), .detail(b)], strategy: .append)   // .replace | .append

// Modals (a journey with its own screens):
let child = router.present(.detail(user), style: .sheet)   // returns the child Router
child.push(.settings)              // the modal has its own stack
router.dismiss()                   // dismiss presented modal
router.dismissSelf()               // a child dismisses itself via its parent link
```

## Render with RouterView

```swift
RouterView(router: router) { route in
    switch route {                 // exhaustive — compiler-enforced completeness
    case .detail(let user): UserDetailView(viewModel: factory.detail(user))
    case .settings:         SettingsView()
    }
}
```

`RouterView` puts the router in the environment, binds `.sheet(item:)` / `.fullScreenCover(item:)` (presentations are **Identifiable items, never booleans**), and gives each modal its **own** nested `RouterView`/stack.

## ViewModels navigate via an intent-named delegate

Keep navigation out of the ViewModel; delegate it (the feature coordinator implements these as one-liners over the `Router`):

```swift
@MainActor protocol UsersListNavigationDelegate: AnyObject {
    func showUserDetail(_ user: User)
}
// in the VM: delegate?.showUserDetail(user)
```

## Deep links

```swift
struct AppDeepLinks: DeepLinkHandler {
    func result(for url: URL) -> DeepLinkResult<AppRoute>? {
        switch url.lastPathComponent {
        case "checkout": DeepLinkResult(routes: [.checkout], strategy: .append)   // protect in-progress state
        default:         nil
        }
    }
}
```

`.replace` resets the stack; `.append` preserves in-progress user state (half-written form + a push tap).

## Modal policy (hybrid)

- **Screen-local UI modals** (filters/pickers that need `Binding`s into the presenting VM) stay **view-level**.
- **Multi-screen flow modals** (checkout, onboarding, auth-expired → login) go through `router.present(_:)` with a nested `RouterView`.

Rule of thumb: *modal edits the presenting screen's state → view-level; modal is a journey with its own screens → router.*

## Notes

- Ownership: the app shell holds the root coordinator (`@State`) → the coordinator owns its `Router` → `RouterView` **receives** it (never creates it).
- Route payloads are entities (not IDs); that is deliberate and trades away state-restoration friendliness.
- Composition: one `Router` per tab; cross-feature navigation via an app-level enum wrapping feature routes (`AppRoute.users(UsersRoute)`).

See also: [Architecture](../ARCHITECTURE.md) · [Getting Started](../GettingStarted.md)
