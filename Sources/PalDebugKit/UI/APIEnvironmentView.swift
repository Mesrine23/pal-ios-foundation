#if canImport(UIKit)
import SwiftUI

/// The API tab: pick the active environment per client; add/remove custom ones.
struct APIEnvironmentView: View {

    let store: EnvironmentStore
    @State private var showingAdd = false

    var body: some View {
        List {
            ForEach(clientIDs, id: \.rawValue) { clientID in
                Section(clientID.rawValue == ClientID.default.rawValue ? "Environments" : clientID.rawValue) {
                    let envs = store.environments[clientID] ?? []
                    ForEach(envs) { env in
                        row(env, clientID: clientID)
                    }
                    .onDelete { offsets in
                        for index in offsets { store.removeCustom(envs[index], for: clientID) }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEnvironmentView { name, url in
                store.addCustom(APIEnvironment(name: name, baseURL: url, isCustom: true), for: .default)
            }
        }
    }

    private var clientIDs: [ClientID] {
        store.environments.keys.sorted { $0.rawValue < $1.rawValue }
    }

    private func row(_ env: APIEnvironment, clientID: ClientID) -> some View {
        Button {
            store.select(env, for: clientID)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(env.name)
                    Text(env.baseURL.absoluteString).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if store.selected[clientID]?.id == env.id {
                    Image(systemName: "checkmark").foregroundStyle(.tint)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

private struct AddEnvironmentView: View {
    let onAdd: (String, URL) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var urlString = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Base URL", text: $urlString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
            }
            .navigationTitle("Add environment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let url = URL(string: urlString) { onAdd(name, url) }
                        dismiss()
                    }
                    .disabled(name.isEmpty || URL(string: urlString) == nil)
                }
            }
        }
    }
}
#endif
