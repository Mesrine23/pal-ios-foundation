import SwiftUI

/// The design system's token set: semantic slots the foundation's components read,
/// values the app supplies. **Opt-in** — everything works against ``system`` with
/// zero configuration; branding is one line at the root.
///
/// `Theme` is intentionally a **minimal bridge**: it carries only the slots Pal's
/// own components need to render on-brand. An app with a rich design system keeps
/// its full token layer and maps the relevant subset into `Theme`.
///
/// ```swift
/// RootView().theme(.myBrand)
///
/// extension Theme {
///     static var myBrand: Theme {
///         var theme = Theme.system
///         theme.colors.accent = Color("BrandAccent")
///         theme.typography.body = .custom("FiraSans", size: 16, relativeTo: .body)
///         theme.shadows.level1 = ThemeShadow(color: .black.opacity(0.1), radius: 6, y: 3)
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

    /// The elevation scale.
    public var shadows: ThemeShadows

    /// Creates a theme.
    public init(
        colors: ThemeColors = .system,
        typography: ThemeTypography = .system,
        spacing: ThemeSpacing = .system,
        radii: ThemeRadii = .system,
        shadows: ThemeShadows = .system
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.shadows = shadows
    }

    /// The zero-configuration default: system colors, fonts, and scales.
    public static var system: Theme {
        Theme()
    }
}
