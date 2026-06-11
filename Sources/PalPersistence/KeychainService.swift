import Foundation
import Security

/// The production ``KeychainStorage``: generic-password items, JSON-encoded values,
/// create-or-replace semantics.
public struct KeychainService: KeychainStorage {

    /// Creates a Keychain service.
    public init() {}

    public func get<V>(_ key: KeychainKey<V>) throws(KeychainError) -> V? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let value = try? JSONDecoder().decode(V.self, from: data) else {
                throw .decodingFailed
            }
            return value
        case errSecItemNotFound:
            return nil
        default:
            throw .unexpectedStatus(status)
        }
    }

    public func set<V>(_ value: V, for key: KeychainKey<V>) throws(KeychainError) {
        guard let data = try? JSONEncoder().encode(value) else {
            throw .encodingFailed
        }

        var addQuery = baseQuery(for: key)
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = key.accessibility.secValue

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

        switch addStatus {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            let attributes: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(baseQuery(for: key) as CFDictionary, attributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw .unexpectedStatus(updateStatus)
            }
        default:
            throw .unexpectedStatus(addStatus)
        }
    }

    public func delete<V>(_ key: KeychainKey<V>) throws(KeychainError) {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw .unexpectedStatus(status)
        }
    }

    private func baseQuery<V>(for key: KeychainKey<V>) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.service,
            kSecAttrAccount as String: key.account,
        ]
    }
}
