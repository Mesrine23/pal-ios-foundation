import SwiftUI

/// The "loaded, but nothing here" state: icon, title, optional message, optional action.
/// Success with an empty collection is not an error — it gets its own face.
public struct EmptyStateView: View {

    private let systemImage: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (@MainActor () -> Void)?

    @Environment(\.theme) private var theme

    /// Creates an empty state.
    /// - Parameters:
    ///   - systemImage: The SF Symbol illustrating the emptiness.
    ///   - title: The already-localized headline.
    ///   - message: An optional, already-localized explanation.
    ///   - actionTitle: The optional call-to-action label.
    ///   - action: The call-to-action handler.
    public init(
        systemImage: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: theme.spacing.m) {
            Image(systemName: systemImage)
                .font(theme.typography.largeTitle)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityHidden(true)
            Text(title)
                .textStyle(.title)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .textStyle(.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.accent)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
