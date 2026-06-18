# PalAuth

> The thin glue that lets PalNetworking store tokens in the Keychain — without Networking and Persistence depending on each other. Dependencies: PalCore, PalNetworking, PalPersistence.

`import PalAuth`

## What it gives you

- **`KeychainTokenStore`** — implements PalNetworking's `TokenStore` (`tokens()` / `save(_:)` / `clear()`) backed by PalPersistence's `KeychainService` + a `KeychainKey<AuthTokens>`.

That is the whole product. It exists so Networking stays storage-agnostic and Persistence stays auth-agnostic; the dependency on both lives only here.

## Usage

```swift
import PalAuth

let store = KeychainTokenStore(
    keychain: KeychainService(),
    key: .authTokens          // ships a convenience KeychainKey<AuthTokens>; override if you prefer your own
)

let tokenProvider = TokenProvider(store: store, refresher: myRefreshService)
```

Wire `tokenProvider` into `AuthInterceptor` (see [PalNetworking](PalNetworking.md)). On logout, `store.clear()` is called for you when the session ends.

## Notes

- `AuthTokens { accessToken, refreshToken, expiresAt }` lives in PalNetworking (so the auth machinery can use it); PalAuth only bridges it to storage.
- Want a non-Keychain store (e.g. in-memory for tests)? Conform your own type to `TokenStore` — you do not need this product for that.

See also: [PalNetworking](PalNetworking.md) · [PalPersistence](PalPersistence.md)
