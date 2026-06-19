/// Fetches the users list. One method, `execute` — the app-layer use-case convention.
nonisolated protocol FetchUsersUseCaseProtocol: Sendable {

    /// Loads the users.
    /// - Parameter forceRefresh: When `true`, bypasses the cache.
    func execute(forceRefresh: Bool) async throws -> [User]
}

/// The production ``FetchUsersUseCaseProtocol`` — delegates to the repository.
nonisolated struct FetchUsersUseCase: FetchUsersUseCaseProtocol {

    private let usersRepo: any UsersRepoProtocol

    /// Creates the use case.
    /// - Parameter usersRepo: The repository providing user data.
    init(usersRepo: any UsersRepoProtocol) {
        self.usersRepo = usersRepo
    }

    func execute(forceRefresh: Bool) async throws -> [User] {
        try await usersRepo.getUsers(forceRefresh: forceRefresh)
    }
}
