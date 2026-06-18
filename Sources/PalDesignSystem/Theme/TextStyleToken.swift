import SwiftUI

/// A named text appearance resolved against the active ``Theme``. A struct (not an
/// enum) so apps can add their own tokens via extension:
///
/// ```swift
/// extension TextStyleToken {
///     static let priceTag = TextStyleToken(
///         font: { $0.typography.headline },
///         color: { $0.colors.accent },
///         tracking: 0.5,
///         lineSpacing: 2
///     )
/// }
/// ```
public struct TextStyleToken: Sendable {

    let font: @Sendable (Theme) -> Font
    let color: (@Sendable (Theme) -> Color)?
    let tracking: CGFloat?
    let lineSpacing: CGFloat?

    /// Creates a text style token.
    /// - Parameters:
    ///   - font: Resolves the token's font from the theme.
    ///   - color: Resolves the token's color from the theme; `nil` inherits the context's color.
    ///   - tracking: Letter spacing in points; `nil` leaves it unchanged.
    ///   - lineSpacing: Additional line spacing in points; `nil` leaves it unchanged.
    public init(
        font: @escaping @Sendable (Theme) -> Font,
        color: (@Sendable (Theme) -> Color)? = nil,
        tracking: CGFloat? = nil,
        lineSpacing: CGFloat? = nil
    ) {
        self.font = font
        self.color = color
        self.tracking = tracking
        self.lineSpacing = lineSpacing
    }

    /// Hero/screen titles in primary text color.
    public static let largeTitle = TextStyleToken(font: { $0.typography.largeTitle }, color: { $0.colors.textPrimary })

    /// Section and screen titles in primary text color.
    public static let title = TextStyleToken(font: { $0.typography.title }, color: { $0.colors.textPrimary })

    /// Emphasized body text in primary text color.
    public static let headline = TextStyleToken(font: { $0.typography.headline }, color: { $0.colors.textPrimary })

    /// Default reading text in primary text color.
    public static let body = TextStyleToken(font: { $0.typography.body }, color: { $0.colors.textPrimary })

    /// Supporting text in secondary color.
    public static let caption = TextStyleToken(font: { $0.typography.caption }, color: { $0.colors.textSecondary })
}
