import Foundation

/// The payload of a ``Request``.
public enum HTTPBody: Sendable {

    /// A value encoded as JSON; sets `Content-Type: application/json` unless overridden.
    case json(any Encodable & Sendable)

    /// Raw data with an explicit content type.
    case data(Data, contentType: String)

    /// A `multipart/form-data` body assembled from parts.
    case multipart([MultipartPart])

    /// A file uploaded from disk via an upload task, with an explicit content type.
    case file(URL, contentType: String)
}
