# Pal — Agent Working Guide (AGENTS.md mirror of CLAUDE.md — keep in sync)

Pal is a reusable, zero-dependency iOS foundation: one Swift Package, multiple library products, consumed by apps via SPM. Swift 6 strict concurrency · iOS 17 floor · MVVM + Coordinators · Clean layering (Presentation / Domain / Data).

**Canon:** [Documentation/DECISIONS.md](Documentation/DECISIONS.md) is the single source of truth for every locked decision. [Documentation/ARCHITECTURE.md](Documentation/ARCHITECTURE.md) explains structure and patterns. If anything here seems to conflict, DECISIONS.md wins. Do not relitigate locked decisions — propose changes to the owner instead.

## The law of the codebase

**The foundation ships mechanisms; apps ship values.** Concrete endpoints, user-facing strings, brand tokens, storage keys, analytics events, environments, and validation rules NEVER live in Pal packages — apps supply them via typed keys, static factory extensions, and protocol conformances.

## Build & verify

```bash
swift build        # all package targets
swift test         # smoke + targeted tests
# Example app: open Example/PalExample.xcodeproj (or xcodebuild -project ... -scheme PalExample)
```

Every change must leave `swift build` + `swift test` green and the Example app compiling. CI enforces this on push/PR.

## Package dependency DAG (enforced — never add edges)

`PalCore→∅` · `PalPersistence→Core` · `PalNetworking→Core` · `PalAuth→Networking,Persistence` · `PalPresentation→Core` · `PalNavigation→∅` · `PalDesignSystem→Core,Presentation` · `PalAnalytics→Core` · `PalFeatureFlags→Core` · `PalDebugKit→Core,Networking,Persistence` (not DesignSystem).

Every target declares ALL modules it directly imports (no transitive reliance). No SwiftUI in PalCore. Zero external dependencies in the package — Swinject exists only app-side (Example).

## Naming conventions (SCOPED — binding)

- **App-layer seams** (in apps and the Example app) use explicit suffixes:
  - Use cases: `‹Verb›‹Entity›UseCaseProtocol` → impl `‹Verb›‹Entity›UseCase`, exactly ONE method `execute(...)`. No marker base protocol.
  - Repositories: `‹Entity›RepoProtocol` → impl `‹Entity›Repository` (deliberate asymmetry). Entity-based by default; capability-based when the seam is a capability.
  - Navigation delegates: `‹Screen›NavigationDelegate` with intent-named methods (`showUserDetail(_:)`).
- **Foundation public API uses standard Swift naming** (Swift API Design Guidelines): `NetworkClient`, `TokenStore`, `Interceptor`, `Routable`, `KeychainService`…
  **GUARD: never rename foundation protocols to add `…Protocol` suffixes.** `TokenStore` must NOT become `TokenStoreProtocol`. The suffix convention is app-layer only.
- Storage/cache verbs are uniform: `get` / `set` / `delete`.

## Clean-code rules (binding)

1. **No user-facing string literals in Views/ViewModels** — String Catalog keys via `String(localized:)`/generated symbols only.
2. **No implementation comments** — self-documenting naming; sole exception: a genuinely non-obvious constraint/workaround, explaining WHY never WHAT. No commented-out code. `// MARK:` dividers permitted. **`///` documentation comments are REQUIRED on every public symbol.**
3. Follow the naming conventions above exactly.
4. **No force-unwraps / `try!` / `as!`** — sole exception: DI resolution at the app's composition root (fail-fast by design).
5. **No `print()`** — `LoggerFactory` only (opt-in). **Never log secrets:** auth headers always redacted; bodies at `.debug` only; `privacy: .private` for dynamic values.
6. **No `AnyView`** or type-erasure workarounds.
7. No magic numbers in UI — theme tokens for spacing/radii where DesignSystem is used.
8. One type per file, file named after the type; extensions as `Type+Feature.swift`.
9. Explicit access control; smallest public surface.
10. Layer rules: Views never touch clients/repos; ViewModels import Domain only; DTO↔entity mapping lives in Data; dependency arrows point inward.
11. Swift 6 hygiene: no `@unchecked Sendable` without written justification; `@MainActor` ViewModels; actors for shared mutable state.
12. Errors are never silently swallowed; mapped at boundaries (`NetworkError` → domain error → `PresentableError`); cancellation never surfaces to users.

## The canonical per-screen pattern

Every screen: `@MainActor @Observable` ViewModel holding `ViewState<Value>` (`idle / loading(previous:) / loaded / failed(error, previous:)`) + the `LoadableViewModelProtocol` runner (`load {}` — auto-cancels the previous in-flight load, swallows cancellation, maps to `PresentableError`) + a View that switches on state. Navigation goes through the screen's `NavigationDelegate`, implemented by the feature coordinator as one-liners over the typed `Router`. Dependencies arrive via `init` (constructor injection from the app-side factory). Load failures → `ViewState`; action failures → `.appAlert`.

## Current status

Phase 0 (scaffold) — see DECISIONS.md §22 for the phase list. Targets contain empty stubs until their phase lands. Tests: smoke test now; targeted tests arrive with Phases 2–3.
