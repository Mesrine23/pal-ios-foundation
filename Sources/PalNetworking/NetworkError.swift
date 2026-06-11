import Foundation

/// Every failure the networking layer can produce. Thrown as a typed error by
/// ``NetworkClient/send(_:)`` so callers handle an exhaustive, known set.
///
/// Repositories map this to domain errors; it never reaches Presentation directly.
public enum NetworkError: Error, Sendable {

    /// The `URLRequest` could not be built (bad base URL, path, or body encoding).
    case invalidRequest

    /// The transport layer failed: offline, timeout, TLS, DNS.
    case transport(URLError)

    /// The server answered outside 200–299; carries the raw body for on-demand
    /// decoding via ``serverError(as:decoder:)``.
    case unacceptableStatus(code: Int, data: Data)

    /// The 2xx body could not be decoded into the request's `Response` type.
    case decoding(DecodingError)

    /// The request was cancelled. Never surface this to users.
    case cancelled
}

public extension NetworkError {

    /// Decodes the server's error body into the given type, when this error is
    /// ``unacceptableStatus(code:data:)``.
    /// - Parameters:
    ///   - type: The backend error payload type.
    ///   - decoder: The decoder to use. Defaults to a fresh `JSONDecoder`.
    /// - Returns: The decoded payload, or `nil` when unavailable or undecodable.
    func serverError<E: Decodable>(as type: E.Type, decoder: JSONDecoder = JSONDecoder()) -> E? {
        guard case .unacceptableStatus(_, let data) = self else { return nil }
        return try? decoder.decode(type, from: data)
    }

    /// Whether retrying the request could plausibly succeed: transient transport
    /// failures and 5xx server responses.
    var isRetriable: Bool {
        switch self {
        case .transport(let urlError):
            [.timedOut, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost, .dnsLookupFailed]
                .contains(urlError.code)
        case .unacceptableStatus(let code, _):
            (500...599).contains(code)
        case .invalidRequest, .decoding, .cancelled:
            false
        }
    }
}
