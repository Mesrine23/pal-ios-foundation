/// A boolean feature toggle with a **safe default**: when the provider has no
/// value (fetch failed, key missing, NoOp provider), the app still behaves sanely.
///
/// Apps declare their flags via extension — flag keys are app values:
/// ```swift
/// extension FeatureFlag {
///     static let newCheckout = FeatureFlag(key: "new_checkout", defaultValue: false)
/// }
/// ```
public struct FeatureFlag: Sendable, Equatable {

    /// The flag's key in the backing provider.
    public let key: String

    /// The value used when the provider has none.
    public let defaultValue: Bool

    /// Creates a flag.
    /// - Parameters:
    ///   - key: The flag's key.
    ///   - defaultValue: The fallback when no value exists. Defaults to `false`.
    public init(key: String, defaultValue: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
