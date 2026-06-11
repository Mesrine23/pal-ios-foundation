/// Does nothing — the default registration. Projects without analytics carry
/// zero SDKs and zero configuration; `track` calls are harmless no-ops.
public struct NoOpAnalyticsTracker: AnalyticsTracker {

    /// Creates a no-op tracker.
    public init() {}

    public func track(_ event: AnalyticsEvent) {}
    public func identify(userID: String?) {}
    public func setUserProperty(_ value: String?, for key: String) {}
    public func reset() {}
}
