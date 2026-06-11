/// Typed UserDefaults access. Conform a mock to this in tests;
/// production code uses ``UserDefaultsService``.
///
/// Non-throwing by design: defaults writes do not meaningfully fail —
/// the one justified asymmetry with ``KeychainStorage``.
public protocol DefaultsStorage: Sendable {

    /// Reads the value for the key, falling back to the key's default when absent.
    func get<V>(_ key: DefaultsKey<V>) -> V?

    /// Creates or replaces the value for the key.
    func set<V>(_ value: V, for key: DefaultsKey<V>)

    /// Removes the value for the key.
    func delete<V>(_ key: DefaultsKey<V>)
}
