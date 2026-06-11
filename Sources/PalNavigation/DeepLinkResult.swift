/// What a deep link resolves to: the routes plus how to apply them.
public struct DeepLinkResult<Route: Routable>: Sendable, Equatable {

    /// The routes representing the linked location.
    public let routes: [Route]

    /// How the routes are applied to the current stack.
    public let strategy: NavigationStrategy

    /// Creates a deep-link result.
    /// - Parameters:
    ///   - routes: The routes representing the linked location.
    ///   - strategy: How to apply them. Defaults to `.replace`.
    public init(routes: [Route], strategy: NavigationStrategy = .replace) {
        self.routes = routes
        self.strategy = strategy
    }
}
