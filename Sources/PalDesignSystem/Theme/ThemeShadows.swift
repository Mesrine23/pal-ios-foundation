import SwiftUI

/// A single elevation / drop-shadow token.
public struct ThemeShadow: Sendable {

    /// The shadow color (typically a low-opacity black).
    public var color: Color

    /// The blur radius.
    public var radius: CGFloat

    /// The horizontal offset.
    public var x: CGFloat

    /// The vertical offset.
    public var y: CGFloat

    /// Creates a shadow token.
    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

/// The theme's elevation scale.
public struct ThemeShadows: Sendable {

    /// Subtle elevation — cards, list rows.
    public var level1: ThemeShadow

    /// Stronger elevation — sheets, popovers, prominent cards.
    public var level2: ThemeShadow

    /// Creates an elevation scale.
    public init(level1: ThemeShadow, level2: ThemeShadow) {
        self.level1 = level1
        self.level2 = level2
    }

    /// A restrained default elevation scale.
    public static var system: ThemeShadows {
        ThemeShadows(
            level1: ThemeShadow(color: .black.opacity(0.08), radius: 4, y: 2),
            level2: ThemeShadow(color: .black.opacity(0.12), radius: 12, y: 6)
        )
    }
}
