import Foundation
import Observation
import PalPersistence

/// Drives the API-switcher UI and persists the active environment per client.
/// The synchronous read path for request routing lives in ``EnvironmentResolver``;
/// this type owns the observable state and the change broadcast.
@MainActor @Observable
final class EnvironmentStore {

    private(set) var environments: [ClientID: [APIEnvironment]] = [:]
    private(set) var selected: [ClientID: APIEnvironment] = [:]

    @ObservationIgnored private let defaults: UserDefaultsService
    @ObservationIgnored let changes: AsyncStream<EnvironmentChanged>
    @ObservationIgnored private let continuation: AsyncStream<EnvironmentChanged>.Continuation

    init(defaults: UserDefaultsService = UserDefaultsService()) {
        self.defaults = defaults
        let (stream, continuation) = AsyncStream.makeStream(of: EnvironmentChanged.self)
        self.changes = stream
        self.continuation = continuation
        let rawSelected = defaults.get(.palDebugSelectedEnvironments) ?? [:]
        self.selected = rawSelected.reduce(into: [:]) { $0[ClientID($1.key)] = $1.value }
    }

    /// Registers a client's environments (merging any persisted custom ones) and
    /// seeds a selection if none exists yet.
    func register(_ envs: [APIEnvironment], for clientID: ClientID) {
        let custom = (defaults.get(.palDebugCustomEnvironments) ?? [:])[clientID.rawValue] ?? []
        environments[clientID] = envs + custom
        if selected[clientID] == nil, let first = envs.first ?? custom.first {
            selected[clientID] = first
            persistSelected()
        }
    }

    /// Selects an environment and broadcasts the change.
    func select(_ environment: APIEnvironment, for clientID: ClientID) {
        selected[clientID] = environment
        persistSelected()
        continuation.yield(EnvironmentChanged(clientID: clientID, environment: environment))
    }

    func addCustom(_ environment: APIEnvironment, for clientID: ClientID) {
        var byClient = defaults.get(.palDebugCustomEnvironments) ?? [:]
        byClient[clientID.rawValue, default: []].append(environment)
        defaults.set(byClient, for: .palDebugCustomEnvironments)
        environments[clientID, default: []].append(environment)
    }

    func removeCustom(_ environment: APIEnvironment, for clientID: ClientID) {
        guard environment.isCustom else { return }
        var byClient = defaults.get(.palDebugCustomEnvironments) ?? [:]
        byClient[clientID.rawValue]?.removeAll { $0.id == environment.id }
        defaults.set(byClient, for: .palDebugCustomEnvironments)
        environments[clientID]?.removeAll { $0.id == environment.id }
        if selected[clientID]?.id == environment.id {
            selected[clientID] = environments[clientID]?.first
            persistSelected()
        }
    }

    private func persistSelected() {
        let raw = selected.reduce(into: [String: APIEnvironment]()) { $0[$1.key.rawValue] = $1.value }
        defaults.set(raw, for: .palDebugSelectedEnvironments)
    }
}
