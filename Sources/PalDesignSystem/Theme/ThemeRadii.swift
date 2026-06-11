import Foundation

/// The theme's corner-radius scale.
public struct ThemeRadii: Sendable {

    /// Small: chips, tags, small controls.
    public var s: CGFloat

    /// Medium: buttons, cards.
    public var m: CGFloat

    /// Large: sheets, prominent cards.
    public var l: CGFloat

    /// Creates a radius scale.
    public init(s: CGFloat, m: CGFloat, l: CGFloat) {
        self.s = s
        self.m = m
        self.l = l
    }

    /// The default 4/10/16 scale.
    public static var system: ThemeRadii {
        ThemeRadii(s: 4, m: 10, l: 16)
    }
}
