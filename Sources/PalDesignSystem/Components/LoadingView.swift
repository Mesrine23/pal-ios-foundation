import SwiftUI

/// The uniform loading state: a centered spinner with an optional message.
public struct LoadingView: View {

    private let message: String?

    @Environment(\.theme) private var theme

    /// Creates a loading view.
    /// - Parameter message: An optional, already-localized message under the spinner.
    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: theme.spacing.m) {
            ProgressView()
            if let message {
                Text(message).textStyle(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
