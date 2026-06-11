import Foundation

/// Maps incoming URLs to typed routes. **App-implemented** — only the app knows
/// its URL scheme and route mapping; the coordinator applies the result via
/// ``Router/navigate(to:strategy:)``.
///
/// ```swift
/// struct AppDeepLinkHandler: DeepLinkHandler {
///     func result(for url: URL) -> DeepLinkResult<AppRoute>? {
///         switch url.host {
///         case "checkout": DeepLinkResult(routes: [.checkout], strategy: .append)
///         default: nil
///         }
///     }
/// }
/// ```
public protocol DeepLinkHandler: Sendable {

    /// The app's route type.
    associatedtype Route: Routable

    /// Resolves a URL into routes, or `nil` when the URL is not recognized.
    func result(for url: URL) -> DeepLinkResult<Route>?
}
