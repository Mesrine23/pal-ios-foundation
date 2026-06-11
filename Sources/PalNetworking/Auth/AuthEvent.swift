/// Auth lifecycle notifications streamed by ``TokenProvider/events``.
public enum AuthEvent: Sendable, Equatable {

    /// Tokens were refreshed successfully.
    case refreshed

    /// The session ended (no refresh token, or refresh failed) — route to login.
    case loggedOut
}
