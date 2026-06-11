import SwiftUI

private struct TextStyleModifier: ViewModifier {

    let token: TextStyleToken

    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        if let color = token.color {
            content.font(token.font(theme)).foregroundStyle(color(theme))
        } else {
            content.font(token.font(theme))
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
