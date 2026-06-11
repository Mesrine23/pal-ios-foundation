/// Typed, throwing Keychain access. Conform a mock to this in tests;
/// production code uses ``KeychainService``.
public protocol KeychainStorage: Sendable {

    /// Reads the value for the key.
    /// - Returns: The stored value, or `nil` when no item exists.
    /// - Throws: ``KeychainError`` for decoding or Security framework failures.
    func get<V>(_ key: KeychainKey<V>) throws(KeychainError) -> V?

    /// Creates or replaces the value for the key.
    /// - Throws: ``KeychainError`` for encoding or Security framework failures.
    func set<V>(_ value: V, for key: KeychainKey<V>) throws(KeychainError)

    /// Deletes the value for the key. Deleting a missing item is not an error.
    /// - Throws: ``KeychainError`` for Security framework failures.
    func delete<V>(_ key: KeychainKey<V>) throws(KeychainError)
}
