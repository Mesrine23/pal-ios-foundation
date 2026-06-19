import Foundation
import PalPersistence

/// In-memory mock store, persisted as a single JSON blob via `DefaultsKey` and
/// loaded once. Matching = method + path (query-normalized). Two-level enable:
/// a global flag AND the per-record toggle.
actor MockRegistry {

    private var records: [MockRecord]
    private var globalEnabled: Bool
    private let defaults: UserDefaultsService

    init(defaults: UserDefaultsService = UserDefaultsService()) {
        self.defaults = defaults
        self.records = defaults.get(.palDebugMocks) ?? []
        self.globalEnabled = defaults.get(.palDebugMocksEnabled) ?? false
    }

    /// The matching enabled mock, or `nil` when mocking is off / nothing matches.
    func match(method: String, url: URL?) -> MockRecord? {
        guard globalEnabled, let url else { return nil }
        let path = url.path()
        let method = method.uppercased()
        return records.first {
            $0.isEnabled && $0.method.uppercased() == method && Self.normalize($0.path) == path
        }
    }

    var all: [MockRecord] { records }
    var isGlobalEnabled: Bool { globalEnabled }

    /// The record for a (method, path), regardless of its enabled state — for editing.
    func mock(method: String, path: String) -> MockRecord? {
        let method = method.uppercased()
        let path = Self.normalize(path)
        return records.first { $0.method.uppercased() == method && Self.normalize($0.path) == path }
    }

    /// `"METHOD /path"` keys of the currently-enabled mocks — for list indicators.
    func enabledKeys() -> Set<String> {
        Set(records.filter(\.isEnabled).map { "\($0.method.uppercased()) \(Self.normalize($0.path))" })
    }

    func setGlobalEnabled(_ enabled: Bool) {
        globalEnabled = enabled
        if !enabled {
            // Turning mocking off un-mocks every call (clears each record's toggle).
            records = records.map { var record = $0; record.isEnabled = false; return record }
            persist()
        }
        defaults.set(enabled, for: .palDebugMocksEnabled)
    }

    /// Inserts or replaces a record (matched by `id`).
    func upsert(_ record: MockRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }
        persist()
    }

    func remove(_ id: UUID) {
        records.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        defaults.set(records, for: .palDebugMocks)
    }

    private static func normalize(_ path: String) -> String {
        String(path.prefix { $0 != "?" })
    }
}
