import SwiftUI

/// Renders one navigation context: a `NavigationStack` driven by a ``Router``'s
/// typed path, plus its flow modal — each presented modal gets a **nested
/// RouterView over the modal's child router**, so flows push internally and
/// dismiss as a unit.
///
/// Receives its router (created by the owning coordinator) — it never creates one.
/// The router is also published into the environment for descendant views.
///
/// ```swift
/// RouterView(router: coordinator.router, root: .list) { route in
///     factory.view(for: route)
/// }
/// ```
public struct RouterView<Route: Routable, Destination: View>: View {

    @Bindable private var router: Router<Route>
    private let root: Route
    private let destination: (Route) -> Destination

    /// Creates a router view.
    /// - Parameters:
    ///   - router: The router driving this stack — owned by a coordinator.
    ///   - root: The stack's base screen.
    ///   - destination: Builds the screen for a route (the feature's exhaustive
    ///     destination-factory switch).
    public init(
        router: Router<Route>,
        root: Route,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self._router = Bindable(router)
        self.root = root
        self.destination = destination
    }

    public var body: some View {
        #if os(iOS)
        stack.fullScreenCover(item: modalItem(matching: .fullScreenCover)) { modal in
            RouterView(router: modal.childRouter, root: modal.route, destination: destination)
        }
        #else
        stack
        #endif
    }

    private var stack: some View {
        NavigationStack(path: $router.path) {
            destination(root)
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                }
        }
        .sheet(item: modalItem(matching: .sheet)) { modal in
            RouterView(router: modal.childRouter, root: modal.route, destination: destination)
        }
        .environment(router)
    }

    private func modalItem(matching style: ModalStyle) -> Binding<PresentedModal<Route>?> {
        Binding(
            get: {
                guard let modal = router.presentedModal, presentationStyle(of: modal) == style else {
                    return nil
                }
                return modal
            },
            set: { newValue in
                if newValue == nil, let modal = router.presentedModal, presentationStyle(of: modal) == style {
                    router.dismiss()
                }
            }
        )
    }

    private func presentationStyle(of modal: PresentedModal<Route>) -> ModalStyle {
        #if os(iOS)
        modal.style
        #else
        .sheet
        #endif
    }
}
