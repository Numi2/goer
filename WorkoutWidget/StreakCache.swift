import Foundation

/// A small helper that stores daily totals for each metric inside the shared
/// App Group `UserDefaults`. The data structure is deliberately simple so that
/// it remains readable when you peek into the container while debugging:
///
/// ````
/// [
///   "steps": [
///       "2025-06-23": 10432,
///       "2025-06-22": 11230,
///       ...
///   ]
/// ]
/// ````
///
/// 🚨 **Important**: The cache is **not** meant to be the source of truth –
/// HealthKit is.  The collector that lives inside the main app should refresh
/// this cache after it finishes a HK query and whenever HealthKit sends an
/// `HKObserverQuery` update.
@MainActor
final class StreakCache {

    static let shared = StreakCache()
    private init() {}

    // MARK: User-Defaults plumbing

    private let suiteName = "group.com.example.workoutwidget" // ⚠️  Make sure this matches the real App Group ID.
    private lazy var defaults = UserDefaults(suiteName: suiteName) ?? .standard

    private let storageKey = "StreakCache.totals" // <Metric : <Day : Value>>

    private var storage: [String: [String: Double]] {
        get {
            defaults.object(forKey: storageKey) as? [String: [String: Double]] ?? [:]
        }
        set {
            defaults.set(newValue, forKey: storageKey)
        }
    }

    // MARK: Public API

    /// Persists the *total* value for the given metric on the specified day.
    /// If a value already exists for that day it gets **replaced**.
    func save(total: Double, for metric: Metric, on day: Date) {
        let dayKey = Self.dayFormatter.string(from: day)
        var metricDict = storage[metric.rawValue] ?? [:]
        metricDict[dayKey] = total
        storage[metric.rawValue] = metricDict
    }

    /// Returns an array that starts with **today** and goes *back* the requested
    /// number of days (inclusive). Missing days are filled with `0` so the
    /// consumer can always rely on a fixed-length array.
    func totals(for metric: Metric, back days: Int) -> [Double] {
        guard days > 0 else { return [] }

        let metricDict = storage[metric.rawValue] ?? [:]
        var totals: [Double] = []
        let calendar = Calendar.current
        for offset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                let key = Self.dayFormatter.string(from: date)
                totals.append(metricDict[key] ?? 0)
            }
        }
        return totals
    }

    // MARK: Formatter

    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
