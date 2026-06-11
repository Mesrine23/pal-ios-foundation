import Foundation

/// A typed UserDefaults key: the value type travels with the key, so reads and
/// writes are compile-time checked.
///
/// Apps declare their keys as static factories:
/// ```swift
/// extension DefaultsKey where Value == Bool {
///     static var hasSeenOnboarding: DefaultsKey<Bool> {
///         DefaultsKey("hasSeenOnboarding", default: false)
///     }
/// }
/// ```
public struct DefaultsKey<Value: Codable & Sendable>: Sendable {

    /// The raw defaults key name.
    public let name: String

    /// Returned by reads when no value is stored. Optional.
    public let defaultValue: Value?

    /// Creates a typed defaults key.
    /// - Parameters:
    ///   - name: The raw defaults key name.
    ///   - default: The value reads fall back to when nothing is stored.
    public init(_ name: String, default defaultValue: Value? = nil) {
        self.name = name
        self.defaultValue = defaultValue
    }
}
