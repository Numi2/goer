import Foundation

/// A dedicated actor responsible for evaluating health goal streaks off the
/// main thread.  Using an actor guarantees that potentially CPU-heavy work
/// (e.g. analysing months of HealthKit statistics) never blocks the widget
/// timeline generation on the main actor.
actor StreakEngine {

    /// Shared singleton instance.  Using a single instance keeps memory
    /// overhead low and allows for potential caching inside the actor later
    /// without synchronisation headaches.
    static let shared = StreakEngine()

    /// Counts how many consecutive *totals* (starting **today**) meet or
    /// exceed the given **threshold**.
    ///
    /// - Parameters:
    ///   - totals: Array of daily totals where `totals[0]` is *today*.
    ///   - threshold: The per-day goal the user must reach to keep the streak
    ///     alive.
    /// - Returns: The current streak length.
    func evaluate(totals: [Double], threshold: Double) -> Int {
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
