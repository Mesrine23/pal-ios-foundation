public extension Optional where Wrapped: RangeReplaceableCollection {

    /// The wrapped collection, or an empty one when `nil`.
    ///
    /// Works for `String?`, `[Element]?`, and any other `RangeReplaceableCollection`:
    /// `let name = user.nickname.orEmpty`.
    var orEmpty: Wrapped {
        self ?? Wrapped()
    }
}
