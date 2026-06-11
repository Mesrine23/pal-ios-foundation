public extension Collection {

    /// `true` when the collection contains at least one element.
    var isNotEmpty: Bool {
        !isEmpty
    }

    /// Returns the element at the given index, or `nil` when the index is out of bounds.
    ///
    /// ```swift
    /// let third = items[safe: 2]
    /// ```
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
