#if canImport(UIKit)
import SwiftUI
import UIKit

public extension View {

    /// Calls `action` when the device is shaken. The only way to detect a shake —
    /// it rides UIKit's motion responder chain, which SwiftUI doesn't surface.
    func onShake(perform action: @escaping () -> Void) -> some View {
        background(ShakeDetector(onShake: action))
    }
}

private struct ShakeDetector: UIViewControllerRepresentable {
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeResponderController {
        ShakeResponderController(onShake: onShake)
    }

    func updateUIViewController(_ controller: ShakeResponderController, context: Context) {
        controller.onShake = onShake
    }
}

private final class ShakeResponderController: UIViewController {
    var onShake: () -> Void

    init(onShake: @escaping () -> Void) {
        self.onShake = onShake
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake()
        }
    }
}
#endif
