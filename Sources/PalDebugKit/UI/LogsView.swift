#if canImport(UIKit)
import SwiftUI

/// The Logs tab: an always-visible search over a live list of captured exchanges.
struct LogsView: View {

    let store: NetworkLogStore
    @State private var entries: [NetworkLogEntry] = []
    @State private var query = ""

    var body: some View {
        List {
            ForEach(filtered) { entry in
                NavigationLink { LogDetailView(entry: entry) } label: { NetworkCallRow(entry: entry) }
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView("No requests yet", systemImage: "wifi", description: Text("Captured network calls appear here."))
            }
        }
        .task {
            for await snapshot in await store.stream() {
                entries = snapshot.reversed()
            }
        }
    }

    private var filtered: [NetworkLogEntry] {
        guard !query.isEmpty else { return entries }
        return entries.filter { $0.url.localizedCaseInsensitiveContains(query) }
    }
}

private struct LogDetailView: View {
    let entry: NetworkLogEntry

    var body: some View {
        List {
            Section("Request") {
                LabeledContent("Method", value: entry.method)
                LabeledContent("URL", value: entry.url)
            }

            if !queryItems.isEmpty {
                Section("Query parameters") {
                    ForEach(queryItems, id: \.name) { item in
                        LabeledContent(item.name, value: item.value ?? "")
                    }
                }
            }

            if !entry.requestHeaders.isEmpty {
                Section("Request headers") {
                    ForEach(entry.requestHeaders.sorted { $0.key < $1.key }, id: \.key) { key, value in
                        LabeledContent(key, value: value)
                    }
                }
            }

            if let requestBody = entry.requestBodyPreview {
                Section("Request body") {
                    bodyText(requestBody)
                }
            }

            Section("Response") {
                LabeledContent("Status", value: entry.statusCode.map(String.init) ?? "—")
                if let error = entry.errorDescription {
                    LabeledContent("Error", value: error)
                }
                if let responseBody = entry.responseBodyPreview {
                    bodyText(responseBody)
                }
            }
        }
        .navigationTitle("Request")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var queryItems: [URLQueryItem] {
        URLComponents(string: entry.url)?.queryItems ?? []
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.caption.monospaced())
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#endif
