import SwiftUI

/// The theme's semantic color slots — names describe roles, never values.
public struct ThemeColors: Sendable {

    /// The screen background.
    public var background: Color

    /// Elevated surfaces: cards, sheets, alert chrome.
    public var surface: Color

    /// Primary text.
    public var textPrimary: Color

    /// Secondary, de-emphasized text.
    public var textSecondary: Color

    /// The brand/action color.
    public var accent: Color

    /// Positive outcomes.
    public var success: Color

    /// Cautionary states.
    public var warning: Color

    /// Errors and destructive actions.
    public var danger: Color

    /// Creates a color set.
    public init(
        background: Color,
        surface: Color,
        textPrimary: Color,
        textSecondary: Color,
        accent: Color,
        success: Color,
        warning: Color,
        danger: Color
    ) {
        self.background = background
        self.surface = surface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.accent = accent
        self.success = success
        self.warning = warning
        self.danger = danger
    }

    /// System-native colors — adaptive light/dark with zero configuration.
    public static var system: ThemeColors {
        #if canImport(UIKit)
        ThemeColors(
            background: Color(uiColor: .systemBackground),
            surface: Color(uiColor: .secondarySystemBackground),
            textPrimary: .primary,
            textSecondary: .secondary,
            accent: .accentColor,
            success: .green,
            warning: .orange,
            danger: .red
        )
        #else
        ThemeColors(
            background: Color(nsColor: .windowBackgroundColor),
            surface: Color(nsColor: .controlBackgroundColor),
            textPrimary: .primary,
            textSecondary: .secondary,
            accent: .accentColor,
            success: .green,
            warning: .orange,
            danger: .red
        )
        #endif
    }
}
