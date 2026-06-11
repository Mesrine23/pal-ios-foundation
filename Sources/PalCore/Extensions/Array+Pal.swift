public extension Array {

    /// Appends the element only when it is non-`nil`.
    mutating func appendSafe(_ element: Element?) {
        guard let element else { return }
        append(element)
    }
}

public extension Array where Element: Hashable {

    /// Returns a copy with duplicate elements removed, preserving the original order
    /// of first occurrence.
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
