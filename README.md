# Pal

A reusable, zero-dependency iOS foundation — one Swift Package, multiple focused products — built on Swift 6 strict concurrency, iOS 17+, MVVM + Coordinators, and Clean layering.

| Product | What it gives you |
|---|---|
| `PalCore` | Logging (os.Logger), curated extensions, async utilities, AppInfo, AppLanguage |
| `PalPersistence` | Keychain & UserDefaults services with typed keys, in-memory TTL cache |
| `PalNetworking` | Typed `Request<Response>` client, interceptor pipeline, single-flight auth refresh |
| `PalAuth` | Keychain-backed token store glue |
| `PalPresentation` | `ViewState`, `PresentableError`, the loadable ViewModel runner |
| `PalNavigation` | Typed routes, `Router`, `RouterView`, deep links, flow modals |
| `PalDesignSystem` | Opt-in theming, text styles, state views, alerts (en + el) |
| `PalAnalytics` / `PalFeatureFlags` | Provider-agnostic seams with ready no-op/console/in-memory impls |
| `PalDebugKit` | Shake-to-debug menu: network logs, environment switcher, response mocking |

## Usage

Add the package in Xcode (*File ▸ Add Package Dependencies…*), pin to a version, and import the products you need. A full **Getting Started** guide (app shell + composition root) ships with the Example app.

## Documentation

- [Engineering decisions (canon)](Documentation/DECISIONS.md)
- [Architecture & patterns](Documentation/ARCHITECTURE.md)
- Agent guides: [CLAUDE.md](CLAUDE.md) / [AGENTS.md](AGENTS.md)

## Development

```bash
swift build && swift test
```

The `Example/` app consumes the package via a local path and dogfoods every product. Status: scaffold complete (Phase 0); packages land in phases — see [DECISIONS.md §22](Documentation/DECISIONS.md).
