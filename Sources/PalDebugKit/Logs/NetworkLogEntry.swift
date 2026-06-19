import Foundation

/// One captured network exchange, as shown in the Logs tab. Sensitive request
/// headers are redacted at capture; bodies are capped previews.
struct NetworkLogEntry: Identifiable, Sendable, Equatable {

    let id: UUID
    let timestamp: Date
    let method: String
    let url: String
    let requestHeaders: [String: String]
    let requestBodyPreview: String?
    let statusCode: Int?
    let duration: Duration
    let responseBodyPreview: String?
    let errorDescription: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        method: String,
        url: String,
        requestHeaders: [String: String],
        requestBodyPreview: String? = nil,
        statusCode: Int?,
        duration: Duration,
        responseBodyPreview: String?,
        errorDescription: String?
    ) {
        self.id = id
        self.timestamp = timestamp
        self.method = method
        self.url = url
        self.requestHeaders = requestHeaders
        self.requestBodyPreview = requestBodyPreview
        self.statusCode = statusCode
        self.duration = duration
        self.responseBodyPreview = responseBodyPreview
        self.errorDescription = errorDescription
    }
}
