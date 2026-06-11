import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.system
}

public extension EnvironmentValues {

    /// The active design-system theme; defaults to ``Theme/system``.
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public extension View {

    /// Applies a theme to this hierarchy — typically once, at the app's root.
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
