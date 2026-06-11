import Foundation

/// A typed in-memory cache key with an optional time-to-live.
///
/// Apps declare their keys as static factories:
/// ```swift
/// extension CacheKey where Value == [Supply] {
///     static var supplies: CacheKey<[Supply]> {
///         CacheKey("supplies", ttl: .seconds(300))
///     }
/// }
/// ```
public struct CacheKey<Value: Sendable>: Sendable {

    /// The cache entry name.
    public let name: String

    /// How long stored values stay fresh. `nil` means no expiry.
    public let ttl: Duration?

    /// Creates a typed cache key.
    /// - Parameters:
    ///   - name: The cache entry name.
    ///   - ttl: How long stored values stay fresh; `nil` for no expiry.
    public init(_ name: String, ttl: Duration? = nil) {
        self.name = name
        self.ttl = ttl
    }
}
