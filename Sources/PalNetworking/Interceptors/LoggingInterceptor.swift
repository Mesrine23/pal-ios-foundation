import Foundation
import PalCore
import os

/// Logs each exchange's method, URL, status, and duration at `.debug`
/// (errors at `.error`). Place it outermost so timings include retries.
///
/// Redaction by canon: headers and bodies are never logged; URLs use
/// `privacy: .private` (visible while debugging in Xcode, redacted in
/// collected device logs).
public struct LoggingInterceptor: Interceptor {

    private let logger = LoggerFactory.make(category: "Networking")

    /// Creates a logging interceptor.
    public init() {}

    public func intercept(_ request: TransportRequest, next: Next) async throws(NetworkError) -> NetworkResponse {
        let method = request.urlRequest.httpMethod ?? "GET"
        let url = request.urlRequest.url?.absoluteString ?? "<no url>"
        let clock = ContinuousClock()
        let start = clock.now

        logger.debug("→ \(method, privacy: .public) \(url, privacy: .private)")
        do {
            let response = try await next(request)
            let elapsed = clock.now - start
            logger.debug("← \(response.statusCode, privacy: .public) \(method, privacy: .public) \(url, privacy: .private) in \(String(describing: elapsed), privacy: .public)")
            return response
        } catch {
            let elapsed = clock.now - start
            logger.error("✗ \(method, privacy: .public) \(url, privacy: .private) after \(String(describing: elapsed), privacy: .public) — \(String(describing: error), privacy: .public)")
            throw error
        }
    }
}
