import Foundation

/// A named backend environment the API switcher can select. Apps supply the list;
/// app-specific extras (OAuth creds, extra URLs) belong in the app's reset hook
/// keyed by ``id``, not here — the foundation ships the mechanism, the app the values.
public struct APIEnvironment: Codable, Sendable, Identifiable, Hashable {

    /// Stable identifier (defaults to ``name``) — selection persists against it.
    public let id: String

    /// The display name (e.g. "Production").
    public let name: String

    /// The base URL requests resolve against when this environment is active.
    public let baseURL: URL

    /// Whether the user added this at runtime (only custom entries are deletable).
    public let isCustom: Bool

    /// Creates an environment.
    /// - Parameters:
    ///   - id: A stable id; defaults to `name` (keep names unique).
    ///   - name: The display name.
    ///   - baseURL: The base URL for this environment.
    ///   - isCustom: Whether it was user-added. Defaults to `false`.
    public init(id: String? = nil, name: String, baseURL: URL, isCustom: Bool = false) {
        self.id = id ?? name
        self.name = name
        self.baseURL = baseURL
        self.isCustom = isCustom
    }
}
