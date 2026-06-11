import SwiftUI
import PalPresentation

/// The inline per-topic failure card for partial-failure screens: one section
/// failed (`Result.failure` in the composite content) while the rest loaded.
public struct SectionErrorView: View {

    private let error: PresentableError
    private let retry: (@MainActor () -> Void)?

    @Environment(\.theme) private var theme

    /// Creates a section error card.
    /// - Parameters:
    ///   - error: The section's failure.
    ///   - retry: Re-runs the load. Defaults to `nil` (no button).
    public init(_ error: PresentableError, retry: (@MainActor () -> Void)? = nil) {
        self.error = error
        self.retry = retry
    }

    public var body: some View {
        HStack(spacing: theme.spacing.s) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(theme.colors.warning)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(error.title).textStyle(.headline)
                Text(error.message)
                    .textStyle(.caption)
            }
            Spacer(minLength: 0)
            if error.isRetryable, let retry {
                Button(String(localized: "common.retry", bundle: .module), action: retry)
                    .buttonStyle(.bordered)
                    .tint(theme.colors.accent)
            }
        }
        .padding(theme.spacing.m)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.m))
        .accessibilityElement(children: .combine)
    }
}
