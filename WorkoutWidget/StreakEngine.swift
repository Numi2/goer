import Foundation

/// Evaluates if the user has met their goal for each day and turns the result
/// into a *current streak* count (consecutive days that meet the threshold
/// starting with **today**).
enum StreakEngine {

    /// Takes the list of totals (starting **today**) and counts how many
    /// consecutive values are greater than or equal to **threshold**.
    static func evaluate(totals: [Double], threshold: Double) -> Int {
        var streak = 0
        for value in totals {
            if value >= threshold {
                streak += 1
            } else {
                break // streak interrupted
            }
        }
        return streak
    }
}
