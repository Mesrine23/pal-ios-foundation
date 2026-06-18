import SwiftUI

/// The theme's type scale. Prefer `Font.custom(_:size:relativeTo:)` so Dynamic
/// Type keeps scaling custom fonts; use a fixed `Font.custom(_:size:)` only when
/// the brand requires pixel-fixed sizing (it will not scale with Dynamic Type).
public struct ThemeTypography: Sendable {

    /// Hero/screen titles.
    public var largeTitle: Font

    /// Section and screen titles.
    public var title: Font

    /// Emphasized body text.
    public var headline: Font

    /// Default reading text.
    public var body: Font

    /// Supporting, small text.
    public var caption: Font

    /// Creates a type scale.
    public init(largeTitle: Font, title: Font, headline: Font, body: Font, caption: Font) {
        self.largeTitle = largeTitle
        self.title = title
        self.headline = headline
        self.body = body
        self.caption = caption
    }

    /// The system type scale — fully Dynamic Type aware.
    public static var system: ThemeTypography {
        ThemeTypography(
            largeTitle: .largeTitle,
            title: .title2,
            headline: .headline,
            body: .body,
            caption: .caption
        )
    }
}
