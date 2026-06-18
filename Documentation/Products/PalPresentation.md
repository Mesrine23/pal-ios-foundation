# PalPresentation

> The per-screen contract every ViewModel uses: a four-case state, a presentable error, and an owned async runner. Kills the per-VM flag-zoo (`isLoading` / `showError` / `errorMessage` …). Dependencies: PalCore.

`import PalPresentation`

## What it gives you

- **`ViewState<Value>`** — `idle` · `loading(previous:)` · `loaded(Value)` · `failed(PresentableError, previous:)`. The `previous` payload keeps content on screen during refresh and failed-refresh.
- **`PresentableError`** — `title`, `message`, `isRetryable`; map domain errors via `PresentableErrorConvertible`.
- **`Loader<Value>`** — a `@MainActor @Observable` runner the ViewModel **holds** (one per independently-loadable section). It owns the in-flight `Task`, the state transitions, and cancellation.

## The canonical per-screen pattern

```swift
import PalPresentation

@MainActor @Observable
final class UsersListViewModel {
    let users = Loader<[User]>()                 // one Loader per loadable section
    private let fetchUsers: FetchUsersUseCaseProtocol

    init(fetchUsers: FetchUsersUseCaseProtocol) { self.fetchUsers = fetchUsers }

    func refresh() { users.load { try await self.fetchUsers.execute() } }
}
```

```swift
// The View switches on the loader's state:
switch viewModel.users.state {
case .idle, .loading(previous: nil):           LoadingView()
case .loading(previous: let value?):           content(value).overlay { ProgressView() }
case .loaded(let value):                       content(value)
case .failed(let error, previous: nil):        ErrorView(error) { viewModel.refresh() }
case .failed(let error, previous: let value?): content(value)   // + banner over stale data
}
```

`state` helpers: `value`, `isLoading`, `error`.

## What `Loader.load { }` does for you

- Cancels the previous in-flight load (re-trigger dedupe — search-as-you-type, rapid refresh).
- Sets `.loading(previous:)`, then `.loaded` or `.failed(PresentableError, previous:)`.
- **Swallows `CancellationError`** (cancellation never reaches the user).
- Holds `self` weakly; `state` is `private(set)` (only the loader mutates it).

Variants: `performLoad { } async` for `.task { }` (view-lifecycle cancellation) and `cancel()` for manual control. Rule of thumb: **the runner owns re-trigger cancellation; `.task` owns lifecycle cancellation.**

## Mapping your errors

```swift
enum UserError: Error, PresentableErrorConvertible {
    case notFound, network
    var presentableError: PresentableError {
        switch self {
        case .notFound: PresentableError(title: "Not found", message: "…", isRetryable: false)
        case .network:  .generic
        }
    }
}
```

`Loader` maps anything thrown into a `PresentableError` (using your conformance when present, else `.generic`).

## Multi-section & partial failure

Hold **several** `Loader`s on one ViewModel for independently-loadable sections. For one composite call where a topic may fail without failing the screen, model fields as `Result<Value, PresentableError>` and render an inline `SectionErrorView` (see [PalDesignSystem](PalDesignSystem.md)).

## Notes

- Channel split: **LOAD** failures → `ViewState` (full error or banner over stale data); **ACTION** failures (screen keeps its data) → `.appAlert` (DesignSystem).
- Default strings for `PresentableError` ship localized (en + el); override per error as needed.

See also: [PalDesignSystem](PalDesignSystem.md) (renders these states) · [Architecture](../ARCHITECTURE.md)
