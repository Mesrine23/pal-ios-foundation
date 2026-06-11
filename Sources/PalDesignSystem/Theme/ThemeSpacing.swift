import Foundation

/// The theme's spacing scale — use these instead of magic numbers in layouts.
public struct ThemeSpacing: Sendable {

    /// Extra small: tight intra-element gaps.
    public var xs: CGFloat

    /// Small: related elements.
    public var s: CGFloat

    /// Medium: the default gap.
    public var m: CGFloat

    /// Large: section separation.
    public var l: CGFloat

    /// Extra large: screen-level breathing room.
    public var xl: CGFloat

    /// Creates a spacing scale.
    public init(xs: CGFloat, s: CGFloat, m: CGFloat, l: CGFloat, xl: CGFloat) {
        self.xs = xs
        self.s = s
        self.m = m
        self.l = l
        self.xl = xl
    }

    /// The default 4/8/16/24/32 scale.
    public static var system: ThemeSpacing {
        ThemeSpacing(xs: 4, s: 8, m: 16, l: 24, xl: 32)
    }
}
