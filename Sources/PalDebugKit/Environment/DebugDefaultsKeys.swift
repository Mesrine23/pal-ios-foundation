import PalPersistence

/// DebugKit's own persistence keys (debug state is a mechanism DebugKit owns —
/// distinct from app values). All keyed by ``ClientID/rawValue`` where relevant.
extension DefaultsKey where Value == [String: APIEnvironment] {
    static var palDebugSelectedEnvironments: DefaultsKey<[String: APIEnvironment]> {
        DefaultsKey("pal.debug.selectedEnvironments", default: [:])
    }
}

extension DefaultsKey where Value == [String: [APIEnvironment]] {
    static var palDebugCustomEnvironments: DefaultsKey<[String: [APIEnvironment]]> {
        DefaultsKey("pal.debug.customEnvironments", default: [:])
    }
}

extension DefaultsKey where Value == [MockRecord] {
    static var palDebugMocks: DefaultsKey<[MockRecord]> {
        DefaultsKey("pal.debug.mocks", default: [])
    }
}

extension DefaultsKey where Value == Bool {
    static var palDebugMocksEnabled: DefaultsKey<Bool> {
        DefaultsKey("pal.debug.mocksEnabled", default: false)
    }
}
