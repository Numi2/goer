import Foundation
import HealthKit
import WidgetKit

/// A *very* lightweight HealthKit helper that queries the daily totals and
/// stores them inside `StreakCache`. The real implementation should live
/// inside the main app (not in the widget extension) so that it can execute in
/// the background and respond to HK observer callbacks.
///
/// This stub exists so the rest of the sample compiles in isolation.
@MainActor
final class HKCollector {
    static let shared = HKCollector()
    private init() {}

    private let healthStore = HKHealthStore()

    /// Refreshes *today's* total for the given metric and persists it in the
    /// cache. After saving it triggers a widget reload so that our streak
    /// widget updates instantly.
    func refreshToday(for metric: Metric) async throws {
        // Make sure HealthKit is available & authorised.
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let types = Set([metric.quantityType])
        try await healthStore.requestAuthorization(toShare: [], read: types)

        // Build the predicate for "today".
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        // Sum query.
        let sum: HKQuantity? = try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: metric.quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: stats?.sumQuantity())
            }
            healthStore.execute(query)
        }

        let total = sum?.doubleValue(for: HKUnit.count()) ?? 0

        // Persist & notify widgets.
        StreakCache.shared.save(total: total, for: metric, on: Date())
        WidgetCenter.shared.reloadAllTimelines()
    }
}

