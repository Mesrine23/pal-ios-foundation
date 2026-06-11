import Foundation
import Security

/// When a Keychain item is readable, mapped to `kSecAttrAccessible` values.
public enum KeychainAccessibility: Sendable {

    /// Readable after the first unlock following a restart — the right default for
    /// tokens that background refreshes must reach.
    case afterFirstUnlock

    /// Like ``afterFirstUnlock``, but the item never migrates to a new device.
    case afterFirstUnlockThisDeviceOnly

    /// Readable only while the device is unlocked.
    case whenUnlocked

    /// Like ``whenUnlocked``, but the item never migrates to a new device.
    case whenUnlockedThisDeviceOnly

    var secValue: CFString {
        switch self {
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
}
