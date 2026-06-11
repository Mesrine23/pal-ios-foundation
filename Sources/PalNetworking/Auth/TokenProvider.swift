/// Owns token access and **single-flight refresh**: when N requests hit 401
/// concurrently, exactly one network refresh runs and every caller awaits it.
///
/// The guarantee holds because the in-flight check and assignment happen with no
/// suspension point between them, so the actor can never create a second task
/// while one is registered. Callers that arrive during a refresh join it via
/// actor reentrancy — that interleaving is the design.
///
/// Observe ``events`` from the root coordinator: `.loggedOut` means the session
/// is gone and the app should present login.
public actor TokenProvider {

    private let store: any TokenStore
    private let refresher: any TokenRefreshService
    private var inFlight: Task<String, any Error>?
    private let continuation: AsyncStream<AuthEvent>.Continuation

    /// Auth lifecycle notifications. Single-consumer: iterate from one place
    /// (the root coordinator).
    public nonisolated let events: AsyncStream<AuthEvent>

    /// Creates a token provider.
    /// - Parameters:
    ///   - store: Where tokens persist (Keychain-backed in production via `PalAuth`).
    ///   - refresher: The app's refresh-call implementation.
    public init(store: any TokenStore, refresher: any TokenRefreshService) {
        self.store = store
        self.refresher = refresher
        (events, continuation) = AsyncStream.makeStream(of: AuthEvent.self)
    }

    /// The current access token, or `nil` when logged out.
    public func currentToken() async -> String? {
        await store.tokens()?.accessToken
    }

    /// Refreshes the token pair, coalescing concurrent callers into one network call.
    /// - Returns: The fresh access token.
    /// - Throws: ``AuthError`` when no session exists or the refresh fails;
    ///   both clear the store and emit ``AuthEvent/loggedOut``.
    public func refresh() async throws(AuthError) -> String {
        if let inFlight {
            return try await join(inFlight)
        }
        let task = Task { try await self.performRefresh() }
        inFlight = task
        defer { inFlight = nil }
        return try await join(task)
    }

    private func join(_ task: Task<String, any Error>) async throws(AuthError) -> String {
        do {
            return try await task.value
        } catch let error as AuthError {
            throw error
        } catch {
            throw .refreshFailed
        }
    }

    private func performRefresh() async throws -> String {
        guard let refreshToken = await store.tokens()?.refreshToken else {
            await signOut()
            throw AuthError.notAuthenticated
        }
        do {
            let tokens = try await refresher.refresh(using: refreshToken)
            await store.save(tokens)
            continuation.yield(.refreshed)
            return tokens.accessToken
        } catch {
            await signOut()
            throw AuthError.refreshFailed
        }
    }

    private func signOut() async {
        await store.clear()
        continuation.yield(.loggedOut)
    }
}
