import Foundation

public extension String {

    /// A copy of the string with leading and trailing whitespace and newlines removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `true` when the string is empty or contains only whitespace and newlines.
    var isBlank: Bool {
        trimmed.isEmpty
    }

    /// The string itself, or `nil` when it is empty.
    ///
    /// Useful for collapsing empty values in optional chains:
    /// `user.nickname.nilIfEmpty ?? user.fullName`.
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    /// `true` when the string is non-empty and every character is a numeric digit.
    var isNumber: Bool {
        !isEmpty && allSatisfy(\.isNumber)
    }
}
