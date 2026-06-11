/// The response type for endpoints that return an empty body on success.
///
/// ```swift
/// extension Request {
///     static func deleteUser(id: Int) -> Request<EmptyResponse> {
///         Request(method: .delete, path: "/users/\(id)")
///     }
/// }
/// ```
public struct EmptyResponse: Decodable, Sendable, Equatable {

    /// Creates an empty response.
    public init() {}

    public init(from decoder: any Decoder) throws {}
}
