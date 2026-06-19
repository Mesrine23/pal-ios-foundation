#if canImport(UIKit)
import SwiftUI

/// The Mocks tab: an always-visible search, a global enable toggle, then every
/// executed call (each once, same row as Logs). Tapping a call opens its stub —
/// mocked toggle, status code, body. Mocking is universal per (method, path).
struct MocksView: View {

    let registry: MockRegistry
    let logStore: NetworkLogStore

    @State private var globalEnabled = false
    @State private var calls: [NetworkLogEntry] = []
    @State private var mockedKeys: Set<String> = []
    @State private var query = ""

    var body: some View {
        List {
            Section {
                Toggle("Enable mocking", isOn: Binding(
                    get: { globalEnabled },
                    set: { newValue in
                        globalEnabled = newValue
                        Task { await registry.setGlobalEnabled(newValue); await refreshMocked() }
                    }
                ))
            }

            Section("Calls") {
                ForEach(displayed) { entry in
                    NavigationLink {
                        MockEditorView(
                            registry: registry,
                            globalEnabled: globalEnabled,
                            method: entry.method,
                            path: path(of: entry),
                            seedStatus: entry.statusCode ?? 200,
                            seedBody: entry.responseBodyPreview ?? ""
                        ) {
                            Task { await refreshMocked() }
                        }
                    } label: {
                        HStack {
                            NetworkCallRow(entry: entry)
                            if mockedKeys.contains(key(entry)) {
                                Spacer(minLength: 4)
                                Image(systemName: "circle.fill").font(.system(size: 8)).foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .overlay {
            if calls.isEmpty {
                ContentUnavailableView("No requests yet", systemImage: "circle.dashed", description: Text("Executed calls you can mock appear here."))
            }
        }
        .task {
            await refreshMocked()
            for await snapshot in await logStore.stream() {
                calls = dedup(snapshot)
            }
        }
    }

    private var filtered: [NetworkLogEntry] {
        guard !query.isEmpty else { return calls }
        return calls.filter { $0.url.localizedCaseInsensitiveContains(query) }
    }

    /// Mocked calls float to the top; everything else keeps its recency order, so
    /// an un-mocked call drops back to its previous spot.
    private var displayed: [NetworkLogEntry] {
        let base = filtered
        return base.filter { mockedKeys.contains(key($0)) } + base.filter { !mockedKeys.contains(key($0)) }
    }

    private func dedup(_ snapshot: [NetworkLogEntry]) -> [NetworkLogEntry] {
        var seen = Set<String>()
        var result: [NetworkLogEntry] = []
        for entry in snapshot.reversed() where seen.insert(key(entry)).inserted {
            result.append(entry)
        }
        return result
    }

    private func refreshMocked() async {
        globalEnabled = await registry.isGlobalEnabled
        mockedKeys = await registry.enabledKeys()
    }

    private func path(of entry: NetworkLogEntry) -> String {
        URL(string: entry.url)?.path() ?? entry.url
    }

    private func key(_ entry: NetworkLogEntry) -> String {
        "\(entry.method.uppercased()) \(path(of: entry))"
    }
}

private struct MockEditorView: View {
    let registry: MockRegistry
    let globalEnabled: Bool
    let method: String
    let path: String
    let onChange: () -> Void

    @State private var isMocked = false
    @State private var statusCode: Int
    @State private var bodyText: String
    @State private var existingID: UUID?
    @State private var didLoad = false
    @Environment(\.dismiss) private var dismiss

    init(registry: MockRegistry, globalEnabled: Bool, method: String, path: String, seedStatus: Int, seedBody: String, onChange: @escaping () -> Void) {
        self.registry = registry
        self.globalEnabled = globalEnabled
        self.method = method
        self.path = path
        self.onChange = onChange
        self._statusCode = State(initialValue: seedStatus)
        self._bodyText = State(initialValue: seedBody)
    }

    var body: some View {
        Form {
            Toggle("Mocked", isOn: $isMocked)
                .disabled(!globalEnabled)
            Section("Status code") {
                TextField("Status code", value: $statusCode, format: .number)
                    .keyboardType(.numberPad)
            }
            Section("Body") {
                TextEditor(text: $bodyText)
                    .font(.caption.monospaced())
                    .frame(minHeight: 240)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle(path)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { Task { await save(); onChange(); dismiss() } }
            }
        }
        .task {
            guard !didLoad else { return }
            didLoad = true
            if let existing = await registry.mock(method: method, path: path) {
                existingID = existing.id
                isMocked = existing.isEnabled
                statusCode = existing.statusCode
                bodyText = String(decoding: existing.body, as: UTF8.self)
            }
        }
    }

    private func save() async {
        await registry.upsert(MockRecord(
            id: existingID ?? UUID(),
            method: method,
            path: path,
            isEnabled: isMocked,
            statusCode: statusCode,
            body: Data(bodyText.utf8)
        ))
    }
}
#endif
