/// A feature's navigation destinations: an enum whose cases **carry their payloads**
/// (`case detail(User)`), so a route is self-contained data — pushable, presentable,
/// and deep-linkable without side channels.
///
/// ```swift
/// enum UsersRoute: Routable {
///     case list
///     case detail(User)
///     case settings
/// }
/// ```
public protocol Routable: Hashable, Sendable {}
