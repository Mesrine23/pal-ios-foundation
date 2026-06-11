import Foundation

/// The currency of the interceptor chain: the built `URLRequest` plus the
/// per-request ``RequestOptions``, so flags like `requiresAuth` reach interceptors.
public struct TransportRequest: Sendable {

    /// The fully built request about to hit the transport.
    public var urlRequest: URLRequest

    /// The originating request's flags.
    public let options: RequestOptions

    /// Creates a transport request.
    /// - Parameters:
    ///   - urlRequest: The built `URLRequest`.
    ///   - options: The originating request's flags.
    public init(urlRequest: URLRequest, options: RequestOptions) {
        self.urlRequest = urlRequest
        self.options = options
    }
}
