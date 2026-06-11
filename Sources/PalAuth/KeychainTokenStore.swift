import Foundation
import PalCore
import PalNetworking
import PalPersistence
import os

/// The production ``PalNetworking/TokenStore``: persists the auth token pair in
/// the Keychain via ``PalPersistence/KeychainStorage``.
///
/// `TokenStore` is non-throwing by contract, so Keychain failures are logged
/// (never with token values) and reads degrade to `nil`.
public struct KeychainTokenStore: TokenStore {

    private let keychain: any KeychainStorage
    private let key: KeychainKey<AuthTokens>
    private let logger = LoggerFactory.make(category: "Auth")

    /// Creates a Keychain-backed token store.
    /// - Parameters:
    ///   - keychain: The Keychain access to use. Defaults to ``PalPersistence/KeychainService``.
    ///   - key: Where tokens are stored. Defaults to ``PalPersistence/KeychainKey/authTokens``.
    public init(
        keychain: any KeychainStorage = KeychainService(),
        key: KeychainKey<AuthTokens> = .authTokens
    ) {
        self.keychain = keychain
        self.key = key
    }

    public func tokens() async -> AuthTokens? {
        do {
            return try keychain.get(key)
        } catch {
            logger.error("Reading auth tokens failed: \(String(describing: error), privacy: .public)")
            return nil
        }
    }

    public func save(_ tokens: AuthTokens) async {
        do {
            try keychain.set(tokens, for: key)
        } catch {
            logger.error("Persisting auth tokens failed: \(String(describing: error), privacy: .public)")
        }
    }

    public func clear() async {
        do {
            try keychain.delete(key)
        } catch {
            logger.error("Clearing auth tokens failed: \(String(describing: error), privacy: .public)")
        }
    }
}

public extension KeychainKey where Value == AuthTokens {

    /// The default storage location for ``PalNetworking/AuthTokens`` — override by
    /// passing a custom key to ``KeychainTokenStore``.
    static var authTokens: KeychainKey<AuthTokens> {
        KeychainKey(service: "pal.auth", account: "tokens")
    }
}
