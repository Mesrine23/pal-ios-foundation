import PalCore
import os

/// Logs events to the console during development — see your tracking live
/// without any SDK. Event names are public; parameters stay private.
public struct ConsoleAnalyticsTracker: AnalyticsTracker {

    private let logger = LoggerFactory.make(category: "Analytics")

    /// Creates a console tracker.
    public init() {}

    public func track(_ event: AnalyticsEvent) {
        logger.debug("📊 \(event.name, privacy: .public) \(String(describing: event.parameters), privacy: .private)")
    }

    public func identify(userID: String?) {
        logger.debug("📊 identify \(userID ?? "nil", privacy: .private)")
    }

    public func setUserProperty(_ value: String?, for key: String) {
        logger.debug("📊 property \(key, privacy: .public) = \(value ?? "nil", privacy: .private)")
    }

    public func reset() {
        logger.debug("📊 reset")
    }
}
