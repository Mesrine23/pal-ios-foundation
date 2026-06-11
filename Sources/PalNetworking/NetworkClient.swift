/// Sends typed requests and returns decoded responses. Repositories depend on
/// this protocol; ``HTTPClient`` is the production implementation, and tests
/// substitute a mock returning canned values.
public protocol NetworkClient: Sendable {

    /// Executes the request and decodes the response into the request's `Response` type.
    /// - Parameter request: The typed request to send.
    /// - Returns: The decoded response value.
    /// - Throws: ``NetworkError`` describing exactly what went wrong.
    func send<Response>(_ request: Request<Response>) async throws(NetworkError) -> Response
}
