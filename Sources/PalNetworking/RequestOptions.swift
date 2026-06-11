import Foundation

/// Per-request flags that travel through the interceptor chain alongside the `URLRequest`.
public struct RequestOptions: Sendable {

    /// Whether ``AuthInterceptor`` should attach a token and handle 401s.
    /// Set `false` on the token-refresh request itself to avoid recursion.
    public var requiresAuth: Bool

    /// Free-form flags for app- or tooling-specific interceptors.
    public var flags: [String: String]

    /// The file to upload via an upload task, set by ``HTTPBody/file(_:contentType:)``.
    public internal(set) var uploadFileURL: URL?

    /// Creates request options.
    /// - Parameters:
    ///   - requiresAuth: Whether the request carries authentication. Defaults to `true`.
    ///   - flags: Free-form flags for custom interceptors. Defaults to empty.
    public init(requiresAuth: Bool = true, flags: [String: String] = [:]) {
        self.requiresAuth = requiresAuth
        self.flags = flags
        self.uploadFileURL = nil
    }
}
