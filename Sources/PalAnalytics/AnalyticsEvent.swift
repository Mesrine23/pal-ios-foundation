/// A trackable event. Apps define their events as static factory extensions —
/// names and parameters are app values and never live in the foundation:
///
/// ```swift
/// extension AnalyticsEvent {
///     static func orderPlaced(total: Double) -> AnalyticsEvent {
///         AnalyticsEvent(name: "order_placed", parameters: ["total": .double(total)])
///     }
/// }
///
/// tracker.track(.orderPlaced(total: cart.total))
/// ```
public struct AnalyticsEvent: Sendable, Equatable {

    /// The event name, in the app's chosen naming scheme.
    public let name: String

    /// The event's typed parameters.
    public let parameters: [String: AnalyticsValue]

    /// Creates an event.
    /// - Parameters:
    ///   - name: The event name.
    ///   - parameters: The typed parameters. Defaults to empty.
    public init(name: String, parameters: [String: AnalyticsValue] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}
