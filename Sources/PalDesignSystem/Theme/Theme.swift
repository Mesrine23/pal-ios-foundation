import SwiftUI

/// The design system's token set: semantic slots the foundation's components read,
/// values the app supplies. **Opt-in** — everything works against ``system`` with
/// zero configuration; branding is one line at the root:
///
/// ```swift
/// RootView().theme(.myBrand)
///
/// extension Theme {
///     static var myBrand: Theme {
///         var theme = Theme.system
///         theme.colors.accent = Color("BrandAccent")
///         theme.typography.body = .custom("FiraSans", size: 16, relativeTo: .body)
///         return theme
///     }
/// }
/// ```
public struct Theme: Sendable {

    /// Semantic colors.
    public var colors: ThemeColors

    /// The type scale.
    public var typography: ThemeTypography

    /// The spacing scale.
    public var spacing: ThemeSpacing

    /// The corner-radius scale.
    public var radii: ThemeRadii

    /// Creates a theme.
    public init(
        colors: ThemeColors = .system,
        typography: ThemeTypography = .system,
        spacing: ThemeSpacing = .system,
        radii: ThemeRadii = .system
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
    }

    /// The zero-configuration default: system colors, fonts, and scales.
    public static var system: Theme {
        Theme()
    }
}
