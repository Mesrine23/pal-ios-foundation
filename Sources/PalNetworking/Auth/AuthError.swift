/// Failures thrown by ``TokenProvider/refresh()``.
public enum AuthError: Error, Sendable, Equatable {

    /// No refresh token exists — the user must log in.
    case notAuthenticated

    /// The refresh call failed — the session was cleared.
    case refreshFailed
}
