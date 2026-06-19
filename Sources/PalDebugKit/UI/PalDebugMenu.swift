#if canImport(UIKit)
import SwiftUI

/// The shake menu: a tab bar over Logs / API / Mocks, plus any app-supplied tabs.
struct PalDebugMenu<ExtraTabs: View>: View {

    let logStore: NetworkLogStore
    let mockRegistry: MockRegistry
    let environmentStore: EnvironmentStore
    let onClose: () -> Void
    @ViewBuilder let extraTabs: () -> ExtraTabs

    var body: some View {
        TabView {
            tab("Logs", systemImage: "list.bullet.rectangle") { LogsView(store: logStore) }
            tab("API", systemImage: "network") { APIEnvironmentView(store: environmentStore) }
            tab("Mocks", systemImage: "circle.dashed") { MocksView(registry: mockRegistry, logStore: logStore) }
            extraTabs()
        }
    }

    private func tab(_ title: LocalizedStringKey, systemImage: String, @ViewBuilder content: () -> some View) -> some View {
        NavigationStack {
            content()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done", action: onClose)
                    }
                }
        }
        .tabItem { Label(title, systemImage: systemImage) }
    }
}
#endif
