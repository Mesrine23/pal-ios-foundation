import Foundation

/// A process-lifetime, in-memory cache with passive per-key TTL.
///
/// Values live only while the app runs — nothing persists across launches.
/// Expiry is evaluated lazily on ``get(_:)`` (delete-on-read); there are no
/// timers or background sweeps, so suspension cannot drift expiry.
///
/// Intended use is repository-level cache-aside:
/// ```swift
/// if !forceRefresh, let cached = await cache.get(.supplies) { return cached }
/// let supplies = try await client.send(.supplies()).map { $0.toDomain() }
/// await cache.set(supplies, for: .supplies)
/// ```
public actor MemoryCache {

    private struct Entry {
        let value: any Sendable
        let expiresAt: Date?
    }

    private var storage: [String: Entry] = [:]

    /// Creates an empty cache.
    public init() {}

    /// Returns the fresh value for the key, or `nil` when absent or expired.
    /// Expired entries are removed on read.
    public func get<V>(_ key: CacheKey<V>) -> V? {
        guard let entry = storage[key.name] else {
            return nil
        }
        if let expiresAt = entry.expiresAt, Date.now >= expiresAt {
            storage[key.name] = nil
            return nil
        }
        return entry.value as? V
    }

    /// Stores a value for the key.
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The typed key to store under.
    ///   - ttl: Overrides the key's TTL for this entry when provided.
    public func set<V>(_ value: V, for key: CacheKey<V>, ttl: Duration? = nil) {
        let effectiveTTL = ttl ?? key.ttl
        storage[key.name] = Entry(
            value: value,
            expiresAt: effectiveTTL.map { Date.now.addingTimeInterval($0.timeInterval) }
        )
    }

    /// Removes the value for the key.
    public func delete<V>(_ key: CacheKey<V>) {
        storage[key.name] = nil
    }

    /// Removes every entry — call on logout.
    public func clear() {
        storage.removeAll()
    }
}

private extension Duration {

    var timeInterval: TimeInterval {
        Double(components.seconds) + Double(components.attoseconds) * 1e-18
    }
}
