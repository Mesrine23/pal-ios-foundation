# PalDebugKit

> A shake-to-debug suite — network logs, environment switching, and response mocking — in an overlay above any app state. Dependencies: PalCore, PalNetworking, PalPersistence (not PalDesignSystem; the debug UI is self-contained).

> **Status: planned (the one product still landing).** Design is locked; implementation is the next build phase. This guide documents the intended v1 so you can plan adoption. Other products are shipped today. See [CONTRIBUTING](../../CONTRIBUTING.md) for status.

`import PalDebugKit`

## What it will give you (v1)

- **Logs** — a live network inspector: method, URL, status, real timing, redacted headers, body preview. Backed by a `DebugInspectorInterceptor` (outermost) + an observable, capped ring-buffer store.
- **API switcher** — change the active environment at runtime; the next request resolves the new base URL with no rebuild. App-defined `APIEnvironment` payloads; custom/localhost entries.
- **Mocks** — stub any captured call: toggle it, body auto-seeded from the captured response, editable status + optional latency. A `MockInterceptor` short-circuits the chain; mocked exchanges still appear in Logs.

## How it plugs in

The inspector and mock seams are ordinary interceptors in the existing onion (see [PalNetworking](PalNetworking.md)), ordered **inspector → mock → Logging → Retry → Auth → transport** — so mocked calls are logged for free and the inspector captures request start + timing.

```swift
// Composition root — gated by YOUR app's DEBUGKIT compilation flag:
#if DEBUGKIT
PalDebugTools.shared.enable(/* environments, log cap, … */)
let interceptors = [
    PalDebugTools.shared.inspectorInterceptor,   // outermost
    PalDebugTools.shared.mockInterceptor,
    LoggingInterceptor(), RetryInterceptor(), AuthInterceptor(tokenProvider: tokenProvider),
]
#else
let interceptors = [LoggingInterceptor(), RetryInterceptor(), AuthInterceptor(tokenProvider: tokenProvider)]
#endif
```

Environment switching reads the current base URL per request via `HTTPClient`'s `baseURLProvider`; switching broadcasts one event so the app can reset (clear tokens, `cache.clear()`, navigation).

## Gating (default-OFF, triple fenced)

1. **Runtime flag** — `PalDebugTools` is OFF until `enable(…)`; the shake is inert otherwise.
2. **App compilation flag `DEBUGKIT`** — wrap `enable(…)` + interceptor wiring in `#if DEBUGKIT`, defined only in the app configurations that should carry tools (e.g. Debug + a Beta config). App Store config never defines it.
3. **Data fence** — the app passes a per-configuration environment list, so release has nothing to switch to.

Full opt-out is absolute: an app that never links PalDebugKit has zero footprint.

## Not in v1 (planned later)

Flags viewer/overrides, Saved Logs export, language override, version spoofing. Tabs register via a `DebugModule` seam, so these are additive.

See also: [Architecture](../ARCHITECTURE.md) · [PalNetworking](PalNetworking.md) · [CONTRIBUTING](../../CONTRIBUTING.md)
