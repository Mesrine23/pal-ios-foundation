import SwiftUI

/// One button of an ``AppAlert``.
public struct AlertAction: Sendable {

    /// The button's role, affecting its styling.
    public enum Role: Sendable {

        /// The default, accent-tinted action.
        case standard

        /// A destructive action, tinted with the theme's danger color.
        case destructive

        /// A neutral cancel action.
        case cancel
    }

    /// The already-localized button label.
    public let title: String

    /// The button's role.
    public let role: Role

    /// Runs when the button is tapped; the alert dismisses afterwards.
    public let action: @MainActor @Sendable () -> Void

    /// Creates an alert action.
    /// - Parameters:
    ///   - title: The already-localized button label.
    ///   - role: The button's role. Defaults to `.standard`.
    ///   - action: The tap handler. Defaults to doing nothing (dismiss only).
    public init(
        _ title: String,
        role: Role = .standard,
        action: @escaping @MainActor @Sendable () -> Void = {}
    ) {
        self.title = title
        self.role = role
        self.action = action
    }

    /// A localized "Cancel" action (ships in English and Greek).
    public static func cancel(_ action: @escaping @MainActor @Sendable () -> Void = {}) -> AlertAction {
        AlertAction(String(localized: "common.cancel", bundle: .module), role: .cancel, action: action)
    }
}
