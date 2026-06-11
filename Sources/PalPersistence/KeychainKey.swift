import Foundation

/// A typed Keychain location: the value type travels with the key, so reads and
/// writes are compile-time checked.
///
/// Apps declare their keys as static factories:
/// ```swift
/// extension KeychainKey where Value == AuthTokens {
///     static var authTokens: KeychainKey<AuthTokens> {
///         KeychainKey(service: "auth", account: "tokens")
///     }
/// }
/// ```
public struct KeychainKey<Value: Codable & Sendable>: Sendable {

    /// The Keychain service attribute (`kSecAttrService`).
    public let service: String

    /// The Keychain account attribute (`kSecAttrAccount`).
    public let account: String

    /// When the item is readable. Defaults to ``KeychainAccessibility/afterFirstUnlock``.
    public let accessibility: KeychainAccessibility

    /// Creates a typed Keychain key.
    /// - Parameters:
    ///   - service: The Keychain service attribute.
    ///   - account: The Keychain account attribute.
    ///   - accessibility: When the item is readable. Defaults to `.afterFirstUnlock`.
    public init(
        service: String,
        account: String,
        accessibility: KeychainAccessibility = .afterFirstUnlock
    ) {
        self.service = service
        self.account = account
        self.accessibility = accessibility
    }
}
