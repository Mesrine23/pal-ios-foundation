/// Fans every call out to multiple trackers — real projects routinely log to an
/// SDK and an internal backend simultaneously.
///
/// ```swift
/// CompositeAnalyticsTracker([FirebaseTrackerAdapter(), BackendTrackerAdapter()])
/// ```
public struct CompositeAnalyticsTracker: AnalyticsTracker {

    private let trackers: [any AnalyticsTracker]

    /// Creates a composite over the given trackers.
    public init(_ trackers: [any AnalyticsTracker]) {
        self.trackers = trackers
    }

    public func track(_ event: AnalyticsEvent) {
        for tracker in trackers {
            tracker.track(event)
        }
    }

    public func identify(userID: String?) {
        for tracker in trackers {
            tracker.identify(userID: userID)
        }
    }

    public func setUserProperty(_ value: String?, for key: String) {
        for tracker in trackers {
            tracker.setUserProperty(value, for: key)
        }
    }

    public func reset() {
        for tracker in trackers {
            tracker.reset()
        }
    }
}
