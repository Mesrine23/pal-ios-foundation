import SwiftUI

private struct OnFirstAppearModifier: ViewModifier {

    let action: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

public extension View {

    /// Runs the action on the FIRST appearance only — unlike `onAppear`, which
    /// fires again on every return to the screen.
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(action: action))
    }
}
