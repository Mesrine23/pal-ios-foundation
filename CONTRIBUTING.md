# Contributing to Pal

> For people — and agents — working **on** Pal. If you are *adopting* Pal in an app, start with [Getting Started](Documentation/GettingStarted.md) instead.

## Build & verify

```bash
swift build        # all package targets
swift test         # smoke + targeted tests
# Example app: open Example/PalExample.xcodeproj (or xcodebuild -project … -scheme PalExample)
```

Every change must leave `swift build` + `swift test` green **and** the Example app compiling. CI enforces this on push/PR (GitHub Actions, macOS runner). The macOS 14 platform floor exists only so the host can build/test; products target iOS — UIKit-only surfaces are gated with `#if canImport(UIKit)`.

## The rules are binding

The naming conventions and the 12 clean-code rules in [DECISIONS.md §4–5](Documentation/DECISIONS.md) (mirrored in [CLAUDE.md](CLAUDE.md) / [AGENTS.md](AGENTS.md)) are binding for humans and agents alike. Highlights worth re-reading before a PR: `///` on every public symbol · no force-unwraps/`AnyView`/`print` · scoped naming (foundation API uses standard Swift naming; the `…Protocol` suffix is app-layer only) · errors mapped at boundaries.

**Documentation follows every change.** When you add or change a public API, a decision, or a product's behavior, update the affected docs in the same change: the relevant [product guide](Documentation/Products/), [DECISIONS.md](Documentation/DECISIONS.md), [ARCHITECTURE.md](Documentation/ARCHITECTURE.md), and the status below.

## Governance: decisions are a living document

[DECISIONS.md](Documentation/DECISIONS.md) records the intended design. Pal is built to be scalable and maintainable, so it is **open to discussion** — propose changes rather than drifting silently. When implementation reality conflicts with the design, **stop, surface the conflict, and record the resolution in the deviations log below.** The design text stays authoritative; this log is the audit trail of approved exceptions.

## Implementation status

Each phase ends GREEN: `swift build` + `swift test` pass and the Example app compiles.

| Phase | Product | Status | Tag |
|---|---|---|---|
| 0 | Scaffold (spec, Package.swift + DAG, agent docs, CI) | ✅ | `v0.1.0` |
| 1 | PalCore — LoggerFactory · extensions · Debouncer/withTimeout · AppInfo · AppLanguage | ✅ | `v0.2.0` |
| 2 | PalPersistence — Keychain · UserDefaults · typed keys · MemoryCache · privacy manifest | ✅ | `v0.3.0` |
| 3 | PalNetworking — Request/TransportRequest · NetworkError · HTTPClient · onion + Logging/Retry/Auth · TokenProvider · multipart/upload | ✅ | `v0.4.0` |
| 4 | PalAuth — KeychainTokenStore | ✅ | `v0.5.0` |
| 5 | PalPresentation — ViewState · PresentableError · `Loader<Value>` (runner reworked in `v0.10.0`) | ✅ | `v0.6.0` |
| 6 | PalNavigation — Routable · Router (strategy API, Identifiable modals) · RouterView · DeepLinkHandler | ✅ | `v0.7.0` |
| 7 | PalDesignSystem — Theme (colors/typography/spacing/radii/shadows) + textStyle · state views · appAlert (extended in `v0.10.0`) | ✅ | `v0.8.0` |
| 8 | PalAnalytics + PalFeatureFlags — protocols + NoOp/Console/Composite/InMemory | ✅ | `v0.9.0` |
| 9 | PalDebugKit — NetworkLogStore + Inspector/Mock interceptors · overlay shake menu · Logs/API/Mocks · `baseURLProvider` env switching | ✅ | `v0.13.0` |
| 10 | Example app — composition root (manual DI) · canonical Users slice (list/detail) + Settings · dogfoods every product | ✅ | `v0.12.0` |
| 11 (deferred) | Broad tests + PalTestSupport · reachability · streaming download-to-disk | — | — |
| 12 (planned) | Notifications — push + local | — | — |

Tests today: smoke + MemoryCache + TokenProvider single-flight + interceptor-chain + Router + Loader (incl. `refresh`) + DebugKit (log ring buffer, inspector capture, mock interceptor 2xx/non-2xx, env store). The Example app builds for the iOS Simulator (0 warnings), dogfooding **all 10 products** (DebugKit wired behind `DEBUGKIT`).

> **Toward `v1.0.0`:** all 10 products ship as of `v0.13.0` (runtime-confirmed in the simulator). `1.0.0` follows a planned **Notifications** (push + local) feature.

## Deviations log

The audit trail of approved exceptions where implementation reality met the design.

- **Phase 1 — macOS 14 platform floor added to `Package.swift`.** `swift build`/`swift test`/CI compile for the host Mac; without a declared floor SPM assumes macOS 10.13 and modern APIs (os.Logger, Duration, Observation) fail. Products remain iOS-targeted; macOS is build-infrastructure only; UIKit-only surfaces get `#if canImport(UIKit)`.
- **Phase 1 — `AppInfo` distribution detection (TestFlight/App Store) deferred.** The modern API (`AppTransaction`) requires StoreKit, breaching Core's Foundation-only rule; the receipt heuristic is deprecated. Ship nothing rather than either cost; `distribution() async` is purely additive later, where the first consumer lives.
- **Phase 2 — privacy manifest added to PalCore as well** (design mentioned only PalPersistence): `AppLanguage` writes `AppleLanguages` via UserDefaults — a required-reason API (CA92.1) — so PalCore must also declare it.
- **Polish pass (post-POC) — status docs were stale.** `CLAUDE.md` "Current status" and the phase list still read "Phase 0 / empty stubs" at `v0.9.0` — caught by the TheLoot adoption agent. Fixed. **Process rule: update status docs every phase.**
- **Polish pass — runner redesigned `LoadableViewModelProtocol` → `Loader<Value>`.** The protocol+extension couldn't keep `state` `private(set)` against a `{get set}` requirement (its canonical example didn't compile) and supported only one loadable state per VM. Replaced by an owned `Loader<Value>` object: encapsulated state, no `loadTask` boilerplate, multiple sections per screen. **Breaking API change (pre-1.0, acceptable).** A compile-tested reference example (`PalPresentationTests`) now guards the canonical pattern from silent rot.
- **Polish pass — PalDesignSystem `Theme` extended + reframed.** Added a shadow/elevation scale (`ThemeShadows` + `.shadow(_ token:)`), a `separator` color, and `tracking`/`lineSpacing` on `TextStyleToken`; softened the custom-font "MUST `relativeTo:`" to allow fixed sizes; documented `Theme` as a deliberate minimal bridge.
- **Documentation pass — consumer-facing docs added; history relocated here.** Added per-product guides (`Documentation/Products/`), a Getting Started guide, and this file; reframed `DECISIONS.md` as a design reference (history moved out) and softened its framing to "open to discussion". Implementation history (phase status + this deviations log) now lives here, separated from the consumer docs.
- **Phase 9 — PalDebugKit is the one UIKit-using package.** Shake detection and above-everything overlay aren't expressible in pure SwiftUI, so DebugKit contains UIKit behind `#if canImport(UIKit)` (`UIViewControllerRepresentable` for `.onShake`, `UIWindow` for the overlay) — the only Pal package importing UIKit; the macOS host build excludes it. `HTTPClient.baseURLProvider` was reintroduced for per-request env switching. Env routing splits into a nonisolated `EnvironmentResolver` (synchronous reads backing the `@Sendable` `baseURLProvider`) + a `@MainActor` `EnvironmentStore` (UI + persistence). `MockRecord` stores latency in milliseconds (`Duration` isn't `Codable`). The debug menu is **deliberately not localized** (developer-facing, not user-facing) — an exception to the en+el rule. DebugModule registration is realized as built-in tabs + a `@ViewBuilder` slot (no type-erased registry, honoring no-`AnyView`).
- **Phase 9 polish (pre-publish, `v0.13.0`).** Pull-to-refresh: added `Loader.refresh(_:)` (in-place reload — no `.loading`, since the refresh control is the indicator) plus the keep-the-scrollable-mounted pattern (empty/error as overlays), after the Example surfaced a "change the refresh control while it is not idle" conflict on a refresh-to-empty. DebugKit UI refined per owner review — Logs: always-visible search, request body + query params in detail, larger body cap; Mocks: a searchable list of every executed call (reusing the Logs row) with a focused 3-control editor (mocked / status / body), mocked-first ordering, and global-off un-mocks everything.
- **Phase 10 built ahead of Phase 9 (owner preference).** A runnable Example showcase (Users canonical slice + Settings) dogfooding the 9 shipped products via manual DI against a public API; PalDebugKit is excluded until Phase 9. Each Pal product was linked into the app target in `project.pbxproj` (sources auto-include via Xcode's synchronized file groups). Because the app target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, the Domain/Data value types are marked `nonisolated` so DTOs decode and entities construct off the main actor — exactly the adoption guidance in [ARCHITECTURE.md](Documentation/ARCHITECTURE.md).
