import Foundation

/// The raw, validated (2xx) result of an HTTP exchange as seen by interceptors —
/// `Sendable` by storing the response's facts rather than `HTTPURLResponse` itself.
public struct NetworkResponse: Sendable {

    /// The HTTP status code.
    public let statusCode: Int

    /// The response headers.
    public let headers: [String: String]

    /// The raw response body.
    public let data: Data

    /// Creates a network response.
    /// - Parameters:
    ///   - statusCode: The HTTP status code.
    ///   - headers: The response headers. Defaults to empty.
    ///   - data: The raw body. Defaults to empty.
    public init(statusCode: Int, headers: [String: String] = [:], data: Data = Data()) {
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
    }
}
