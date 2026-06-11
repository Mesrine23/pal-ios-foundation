/// Answers every flag with its default — the registration for projects without
/// a flags backend. Flag-reading code keeps working unchanged.
public struct NoOpFeatureFlagsProvider: FeatureFlagsProvider {

    /// Creates a defaults-only provider.
    public init() {}

    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        flag.defaultValue
    }
}
