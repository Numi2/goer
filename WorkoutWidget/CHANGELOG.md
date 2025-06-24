# WorkoutWidget – Changelog

All notable changes to this project will be documented in this file.  The
format is loosely based on [Keep a Changelog](https://keepachangelog.com/) and
adheres to [Semantic Versioning](https://semver.org/) wherever possible.

---

## [Unreleased] – 2025-06-24

### Added

* **Current Streak Widget**
  * `StreakWidget.swift` – WidgetKit implementation (small & medium sizes).
  * `SelectMetricIntent.swift` – AppIntent for per-widget configuration
    (metric & threshold).
  * `StreakMetrics.swift` – High-level `Metric` enum plus `MetricAppEnum` for
    AppIntents.
  * `StreakEngine.swift` – Pure-logic helper that converts daily totals into a
    consecutive-day streak length.
  * `StreakCache.swift` – App-Group `UserDefaults` cache that stores daily
    totals per metric (`[Metric : [yyyy-MM-dd : Double]]`).
  * `HKCollector.swift` – Lightweight HealthKit helper that writes today’s
    total into `StreakCache` and triggers a widget reload.
  * `StreakWidgetDocs.txt` – In-depth design & integration notes.

* **Shared Step-Tracking Infrastructure**
  * `Shared/StepTracker.swift` – `@Observable` singleton that polls HealthKit
    every five minutes and publishes a `DailySummaryModel`.
  * `Shared/StepTrackingModel.swift` – Codable models used by daily / hourly /
    monthly widgets.

### Changed

* `WorkoutWidgetBundle.swift` – Registers the new `StreakWidget` in the widget
  bundle.

* Providers for existing widgets (`DailySummaryWidget.swift`,
  `HourlyStepsWidget.swift`, `MonthlyStepsWidget.swift`)
  * Marked `getTimeline` completion closures as `@Sendable` and moved timeline
    construction onto the **main actor** to silence concurrency data-race
    warnings emitted by Xcode 15.

### Removed

* No deletions; only additive work or internal refactorings.

### Notes

* `StreakCache.suiteName` currently contains a placeholder App-Group ID
  (`group.com.example.workoutwidget`).  Remember to update this constant to
  match the real project identifier in both the main app and the widget
  extension targets.

* `HKCollector` is intended to live inside the **main app**, not the widget
  target, so that it can operate in the background and react to
  `HKObserverQuery` updates.

---

Previous versions: see git history prior to this file’s introduction.
