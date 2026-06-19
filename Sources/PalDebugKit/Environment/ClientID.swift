/// Identifies one network client when an app debugs several (auth, media, …).
/// Single-client apps use ``ClientID/default`` and never see the distinction.
public struct ClientID: Hashable, Sendable {

    /// The raw identifier (also the persistence/UI key).
    public let rawValue: String

    /// Creates a client id.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// The sole client of a single-client app.
    public static let `default` = ClientID("default")
}
