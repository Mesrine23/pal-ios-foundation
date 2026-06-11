import SwiftUI

#if canImport(UIKit)
public extension View {

    /// Resigns the first responder, dismissing the keyboard.
    @MainActor
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif
