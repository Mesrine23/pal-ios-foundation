import Foundation

/// A flow modal in flight: `Identifiable` (never a boolean) so SwiftUI keeps its
/// identity straight across dismiss-then-present transitions, carrying the child
/// ``Router`` that drives the modal's internal stack.
@MainActor
public struct PresentedModal<Route: Routable>: Identifiable {

    /// Unique per presentation — a re-presented route is a NEW modal to SwiftUI.
    public nonisolated let id: UUID

    /// The modal flow's first screen.
    public let route: Route

    /// How the modal is presented.
    public let style: ModalStyle

    /// The router driving the modal's internal navigation stack.
    public let childRouter: Router<Route>

    init(route: Route, style: ModalStyle, childRouter: Router<Route>) {
        self.id = UUID()
        self.route = route
        self.style = style
        self.childRouter = childRouter
    }
}
