import os

/// Holds flag values in memory for the app's lifetime: seed it at startup from
/// your remote source, read synchronously everywhere after.
///
/// ```swift
/// let provider = InMemoryFeatureFlagsProvider()
/// let remote = try? await flagsService.fetchFlags()
/// provider.update(remote ?? [:])
///
/// if provider.isEnabled(.newCheckout) { … }
/// ```
public final class InMemoryFeatureFlagsProvider: FeatureFlagsProvider {

    private let storage: OSAllocatedUnfairLock<[String: Bool]>

    /// Creates a provider, optionally pre-seeded (useful for tests and debug builds).
    /// - Parameter values: Initial flag values by key. Defaults to empty.
    public init(values: [String: Bool] = [:]) {
        storage = OSAllocatedUnfairLock(initialState: values)
    }

    /// Replaces all flag values — call once after fetching at app start.
    public func update(_ values: [String: Bool]) {
        storage.withLock { $0 = values }
    }

    /// Sets a single flag value — the seam debug tooling uses for overrides.
    public func set(_ value: Bool, forKey key: String) {
        storage.withLock { $0[key] = value }
    }

    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        storage.withLock { $0[flag.key] } ?? flag.defaultValue
    }
}
