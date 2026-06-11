import Foundation

public extension Double {

    /// Returns the value rounded to the given number of decimal places.
    /// - Parameter places: The number of decimal places; values below zero are treated as zero.
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(max(places, 0)))
        return (self * multiplier).rounded() / multiplier
    }
}
