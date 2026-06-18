import SwiftUI

private struct TextStyleModifier: ViewModifier {

    let token: TextStyleToken

    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        applyColor(
            to: content
                .font(token.font(theme))
                .tracking(token.tracking ?? 0)
                .lineSpacing(token.lineSpacing ?? 0)
        )
    }

    @ViewBuilder
    private func applyColor(to view: some View) -> some View {
        if let color = token.color {
            view.foregroundStyle(color(theme))
        } else {
            view
        }
    }
}

public extension View {

    /// Applies a themed text style. Apply LAST — the result is `some View`,
    /// so `Text`-specific chaining (bold, concatenation) must happen before.
    func textStyle(_ token: TextStyleToken) -> some View {
        modifier(TextStyleModifier(token: token))
    }
}
