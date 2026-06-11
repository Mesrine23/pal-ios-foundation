/// How a batch of routes (typically from a deep link) is applied to the stack.
public enum NavigationStrategy: Sendable, Equatable {

    /// Reset the stack to exactly these routes — login→home transitions, cold-start links.
    case replace

    /// Push these routes on top of the current stack — protects in-progress user
    /// state when a notification arrives mid-flow.
    case append
}
