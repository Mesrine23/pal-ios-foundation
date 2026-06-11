import Foundation

/// Delays work until a quiet period has elapsed, cancelling any pending invocation
/// when called again — the search-as-you-type primitive.
///
/// ```swift
/// private let debouncer = Debouncer(duration: .milliseconds(300))
///
/// func searchTextChanged(_ text: String) {
///     debouncer.call { self.performSearch(text) }
/// }
/// ```
@MainActor
public final class Debouncer {

    private let duration: Duration
    private var task: Task<Void, Never>?

    /// Creates a debouncer.
    /// - Parameter duration: The quiet period that must elapse before the action runs.
    public init(duration: Duration) {
        self.duration = duration
    }

    /// Schedules the action after the quiet period, cancelling any previously scheduled action.
    /// - Parameter action: The work to perform once the debounce interval passes uninterrupted.
    public func call(_ action: @escaping @MainActor () -> Void) {
        task?.cancel()
        task = Task { [duration] in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else { return }
            action()
        }
    }

    /// Cancels any pending action without scheduling a new one.
    public func cancel() {
        task?.cancel()
        task = nil
    }
}
