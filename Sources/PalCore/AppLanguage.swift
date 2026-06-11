import Foundation

/// A language the host app is localized in, plus helpers for reading and overriding
/// the app's language without bundle swizzling.
///
/// The default, recommended flow is Apple's per-app language setting in iOS Settings —
/// it requires no code. Use ``setOverride(_:)`` only for in-app language switchers;
/// the override takes effect on the next launch (see ``overrideRequiresRestart``).
public struct AppLanguage: Sendable, Hashable, Identifiable {

    /// The language code, e.g. `"en"` or `"el"`.
    public let code: String

    public var id: String { code }

    /// Creates a language from a code such as `"en"`.
    public init(code: String) {
        self.code = code
    }

    /// The language's display name, localized for the given locale.
    /// - Parameter locale: The locale to render the name in. Defaults to the current locale.
    public func localizedName(in locale: Locale = .current) -> String? {
        locale.localizedString(forLanguageCode: code)
    }

    /// The languages the host app ships localizations for, excluding the base localization.
    public static var available: [AppLanguage] {
        Bundle.main.localizations
            .filter { $0.caseInsensitiveCompare("Base") != .orderedSame }
            .map(AppLanguage.init(code:))
    }

    /// The language the app is currently displayed in.
    public static var current: AppLanguage {
        AppLanguage(code: Bundle.main.preferredLocalizations.first ?? "en")
    }

    /// Overrides the app's language via the `AppleLanguages` user default, or clears
    /// the override when passing `nil`.
    ///
    /// The change applies on the next launch; show a restart prompt after calling this.
    /// - Parameter language: The language to switch to, or `nil` to follow the system again.
    public static func setOverride(_ language: AppLanguage?) {
        if let language {
            UserDefaults.standard.set([language.code], forKey: appleLanguagesKey)
        } else {
            UserDefaults.standard.removeObject(forKey: appleLanguagesKey)
        }
    }

    /// `true` — language overrides apply on the next app launch, not immediately.
    public static let overrideRequiresRestart = true

    private static let appleLanguagesKey = "AppleLanguages"
}
