import Foundation
import Observation

/// The navigation state machine for one stack: a typed path (never `NavigationPath`)
/// plus at most one presented flow modal. Owned by a feature coordinator;
/// ``RouterView`` receives it and renders.
///
/// Screen-local UI modals (pickers, filters — anything needing Bindings into the
/// presenting ViewModel) stay view-level by canon; only multi-screen flow modals
/// go through ``present(_:style:)``.
@MainActor
@Observable
public final class Router<Route: Routable> {

    /// The navigation stack below the root, inspectable and assignable as plain data.
    public internal(set) var path: [Route] = []

    /// The flow modal currently presented, when any.
    public internal(set) var presentedModal: PresentedModal<Route>?

    /// The presenting router when this router drives a flow modal's internal stack.
    @ObservationIgnored
    public private(set) weak var parent: Router<Route>?

    /// Creates an empty router.
    public init() {}

    /// Pushes a route onto the stack.
    public func push(_ route: Route) {
        path.append(route)
    }

    /// Pops the given number of screens, clamped to the stack's depth.
    /// - Parameter count: How many screens to pop. Defaults to 1.
    public func pop(_ count: Int = 1) {
        path.removeLast(min(max(count, 0), path.count))
    }

    /// Pops every pushed screen, returning to the root.
    public func popToRoot() {
        path.removeAll()
    }

    /// Pops back to the most recent occurrence of the given route; no-op when absent.
    public func pop(to route: Route) {
        guard let index = path.lastIndex(of: route) else { return }
        path.removeLast(path.count - index - 1)
    }

    /// Replaces the whole stack.
    public func replace(with routes: [Route]) {
        path = routes
    }

    /// Applies a batch of routes — the deep-link entry point.
    /// - Parameters:
    ///   - routes: The routes to apply.
    ///   - strategy: `.replace` resets the stack; `.append` stacks on top,
    ///     protecting in-progress user state.
    public func navigate(to routes: [Route], strategy: NavigationStrategy) {
        switch strategy {
        case .replace: path = routes
        case .append: path.append(contentsOf: routes)
        }
    }

    /// Presents a multi-screen flow modal with its own navigation stack.
    /// - Parameters:
    ///   - route: The flow's first screen.
    ///   - style: Sheet or full-screen cover. Defaults to `.sheet`.
    /// - Returns: The child router driving the flow's internal stack — keep it in
    ///   the coordinator to push within the flow; discard it for single-screen modals.
    @discardableResult
    public func present(_ route: Route, style: ModalStyle = .sheet) -> Router<Route> {
        let child = Router<Route>()
        child.parent = self
        presentedModal = PresentedModal(route: route, style: style, childRouter: child)
        return child
    }

    /// Dismisses this router's presented flow modal, when any.
    public func dismiss() {
        presentedModal = nil
    }

    /// Dismisses the flow modal this router drives — the "Done" one-liner from the
    /// last screen of a presented flow.
    public func dismissSelf() {
        parent?.dismiss()
    }
}
