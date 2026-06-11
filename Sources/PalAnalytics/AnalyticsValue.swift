/// A typed analytics parameter value — keeps event payloads `Sendable` and lets
/// provider adapters map values faithfully instead of stringifying everything.
///
/// Literal conformances keep call sites clean: `["total": 42.5, "tier": "gold"]`.
public enum AnalyticsValue: Sendable, Equatable {

    /// A text value.
    case string(String)

    /// An integer value.
    case int(Int)

    /// A floating-point value.
    case double(Double)

    /// A boolean value.
    case bool(Bool)
}

extension AnalyticsValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension AnalyticsValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension AnalyticsValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension AnalyticsValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}
