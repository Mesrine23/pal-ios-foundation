import Foundation

/// A stubbed response for requests matching `method` + `path` (query-normalized).
/// One record per (method, path) — mocking is universal across the app. Persisted
/// as part of the mock registry's JSON blob.
struct MockRecord: Codable, Sendable, Identifiable, Equatable {

    var id: UUID
    var method: String
    var path: String
    var isEnabled: Bool
    var statusCode: Int
    var headers: [String: String]
    var body: Data

    init(
        id: UUID = UUID(),
        method: String,
        path: String,
        isEnabled: Bool = false,
        statusCode: Int = 200,
        headers: [String: String] = [:],
        body: Data = Data()
    ) {
        self.id = id
        self.method = method
        self.path = path
        self.isEnabled = isEnabled
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}
