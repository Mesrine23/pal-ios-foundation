/// The flags seam. The runtime model: fetch flag values ONCE at app start, seed
/// an ``InMemoryFeatureFlagsProvider``, and every `isEnabled` read afterwards is
/// synchronous from memory — no async at call sites, nothing persisted across
/// launches.
public protocol FeatureFlagsProvider: Sendable {

    /// Whether the flag is on, falling back to its `defaultValue` when unknown.
    func isEnabled(_ flag: FeatureFlag) -> Bool
}
