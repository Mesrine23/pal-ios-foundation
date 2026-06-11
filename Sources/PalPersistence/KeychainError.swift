import Foundation

/// Failures thrown by ``KeychainService``. A missing item is NOT an error —
/// reads return `nil` for not-found.
public enum KeychainError: Error, Sendable, Equatable {

    /// The value could not be encoded for storage.
    case encodingFailed

    /// Stored data exists but could not be decoded into the requested type.
    case decodingFailed

    /// A Security framework call failed with the given status code.
    case unexpectedStatus(OSStatus)
}
