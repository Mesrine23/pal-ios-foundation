/// Persists the auth token pair. `PalAuth` ships the Keychain-backed
/// implementation; tests use an in-memory conformance.
public protocol TokenStore: Sendable {

    /// The currently stored tokens, or `nil` when logged out.
    func tokens() async -> AuthTokens?

    /// Stores a token pair, replacing any previous one.
    func save(_ tokens: AuthTokens) async

    /// Removes the stored tokens.
    func clear() async
}
