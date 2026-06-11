/// Continues the interceptor chain toward the transport.
public typealias Next = @Sendable (TransportRequest) async throws(NetworkError) -> NetworkResponse

/// Middleware wrapping the whole HTTP exchange: mutate the request, inspect or
/// replace the response, time the call, retry by re-invoking `next`, or
/// short-circuit by returning without calling `next` at all.
///
/// Interceptors are HTTP-level — they see raw bytes; typed decoding happens in
/// the client after the chain. Recommended order, outermost first:
/// inspector → mock → ``LoggingInterceptor`` → ``RetryInterceptor`` → ``AuthInterceptor``.
public protocol Interceptor: Sendable {

    /// Handles the request, delegating downstream via `next` as needed.
    /// - Parameters:
    ///   - request: The transport request, including per-request flags.
    ///   - next: Continues toward the transport; may be invoked zero, one, or many times.
    /// - Returns: The exchange's validated response.
    /// - Throws: ``NetworkError`` from this interceptor or anything downstream.
    func intercept(_ request: TransportRequest, next: Next) async throws(NetworkError) -> NetworkResponse
}
