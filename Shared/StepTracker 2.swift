/*
Abstract:
`StepTracker` passively observes the user's daily step and distance totals
using HealthKit and exposes them to SwiftUI views. Unlike the existing
`WorkoutManager`, it doesn't require the user to start an explicit workout –
the tracker simply queries HealthKit on a schedule and publishes the results.
*/

import Foundation
import HealthKit

@MainActor
@Observable
final class StepTracker {
    // MARK: - Public published state
    private(set) var dailySummary: DailySummaryModel? = nil

    // MARK: - Private
    private var pollTask: Task<Void, Never>? = nil
    private let pollInterval: TimeInterval = 5 * 60 // 5-minute refresh

    // Singleton (so widgets / views can share one source)
    static let shared = StepTracker()
    private init() {
        startPolling()
    }

    deinit {
        pollTask?.cancel()
    }

    // MARK: - Refresh logic
    func refresh() {
        Task { await fetchDailySummary() }
    }

    private func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            // Request HealthKit authorisation once.
            try? await HealthKitProvider.shared.requestAuthorization()

            while !Task.isCancelled {
                await self?.fetchDailySummary()
                try? await Task.sleep(for: .seconds(pollInterval))
            }
        }
    }

    private func fetchDailySummary() async {
        do {
            let summary = try await HealthKitProvider.shared.fetchDailySummary()
            self.dailySummary = summary
        } catch {
            // Ignore errors (no permission, etc.) – keep previous value.
            print("StepTracker fetch error: \(error)")
        }
    }
}
