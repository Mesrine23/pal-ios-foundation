import SwiftUI

public extension View {

    /// Applies a theme elevation token as a drop shadow.
    func shadow(_ token: ThemeShadow) -> some View {
        shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
}
