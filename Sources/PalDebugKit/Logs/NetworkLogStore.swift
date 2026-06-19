import Foundation

/// A capped, in-memory ring buffer of captured exchanges — **session-only**, never
/// persisted. Observable via ``stream()`` (the UI subscribes; the store never pokes UI).
actor NetworkLogStore {

    private let cap: Int
    private var entries: [NetworkLogEntry] = []
    private var observers: [UUID: AsyncStream<[NetworkLogEntry]>.Continuation] = [:]

    init(cap: Int = 500) {
        self.cap = cap
    }

    /// Appends an entry, evicting oldest beyond the cap, and notifies observers.
    func record(_ entry: NetworkLogEntry) {
        entries.append(entry)
        if entries.count > cap {
            entries.removeFirst(entries.count - cap)
        }
        broadcast()
    }

    /// All buffered entries, oldest first.
    var all: [NetworkLogEntry] { entries }

    /// Empties the buffer and notifies observers.
    func clear() {
        entries.removeAll()
        broadcast()
    }

    /// A live stream that yields the full buffer on subscribe and on every change.
    func stream() -> AsyncStream<[NetworkLogEntry]> {
        let (stream, continuation) = AsyncStream.makeStream(of: [NetworkLogEntry].self)
        let id = UUID()
        observers[id] = continuation
        continuation.yield(entries)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObserver(id) }
        }
        return stream
    }

    private func removeObserver(_ id: UUID) {
        observers[id] = nil
    }

    private func broadcast() {
        for observer in observers.values {
            observer.yield(entries)
        }
    }
}
