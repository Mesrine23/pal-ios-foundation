import Foundation

/// Retries transient failures (see ``NetworkError/isRetriable``) with exponential
/// backoff, respecting task cancellation. Place it outside ``AuthInterceptor`` so
/// auth handling runs fresh on every attempt.
public struct RetryInterceptor: Interceptor {

    private let maxRetries: Int
    private let baseDelay: Duration

    /// Creates a retry interceptor.
    /// - Parameters:
    ///   - maxRetries: Additional attempts after the first failure. Defaults to 2.
    ///   - baseDelay: The first backoff delay; doubles per attempt. Defaults to 300 ms.
    public init(maxRetries: Int = 2, baseDelay: Duration = .milliseconds(300)) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
    }

    public func intercept(_ request: TransportRequest, next: Next) async throws(NetworkError) -> NetworkResponse {
        var attempt = 0
        while true {
            do {
                return try await next(request)
            } catch {
                attempt += 1
                guard error.isRetriable, attempt <= maxRetries else {
                    throw error
                }
                do {
                    try await Task.sleep(for: baseDelay * (1 << (attempt - 1)))
                } catch {
                    throw NetworkError.cancelled
                }
            }
        }
    }
}
