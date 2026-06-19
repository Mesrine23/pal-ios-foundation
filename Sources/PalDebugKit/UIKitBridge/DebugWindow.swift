#if canImport(UIKit)
import SwiftUI
import UIKit

/// Hosts the debug menu in a dedicated `UIWindow` above the alert layer, so it
/// overlays any app state (including presented sheets). Dismissal drops the window.
@MainActor
final class DebugWindow {

    private var window: UIWindow?

    func present(rootView: some View) {
        guard window == nil, let scene = Self.activeScene() else { return }
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        self.window = window
    }

    func dismiss() {
        window?.isHidden = true
        window = nil
    }

    private static func activeScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        return (scenes.first { $0.activationState == .foregroundActive } ?? scenes.first) as? UIWindowScene
    }
}
#endif
