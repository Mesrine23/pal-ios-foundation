import Foundation

/// One part of a `multipart/form-data` body.
public struct MultipartPart: Sendable {

    /// The form field name.
    public let name: String

    /// The filename reported for file parts, or `nil` for plain fields.
    public let filename: String?

    /// The part's MIME type, e.g. `"image/jpeg"`.
    public let mimeType: String

    /// The part's payload.
    public let data: Data

    /// Creates a multipart part.
    /// - Parameters:
    ///   - name: The form field name.
    ///   - filename: The filename for file parts. Defaults to `nil`.
    ///   - mimeType: The part's MIME type. Defaults to `"application/octet-stream"`.
    ///   - data: The part's payload.
    public init(
        name: String,
        filename: String? = nil,
        mimeType: String = "application/octet-stream",
        data: Data
    ) {
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
}
