- [x] DailySummaryWidget: Replace `MetricRow` with shared `MetricDisplay` component
- [x] DailySummaryWidget: Move hard-coded orange accent colour to semantic colour asset
- [x] DailySummaryWidget: Add `.accessibilityLabel` to motivational message

- [x] HourlyStepsWidget: Reconsider 1-minute refresh; document WidgetKit throttling or relax to 15 minutes
- [x] HourlyStepsWidget: Change `hourlySteps` values to `Double` for future metrics
- [x] HourlyStepsWidget: Generate time-axis labels with `DateFormatter` respecting locale
- [x] HourlyStepsWidget: (Optional) Add "data as of…" caption if real-time accuracy is important

- [x] MonthlyStepsWidget: Use `daysInMonth` to iterate, avoiding unused views in shorter months
- [x] MonthlyStepsWidget: Extract goal-day threshold (8 000 steps) to constant or user setting
- [x] MonthlyStepsWidget: Add accessibility labels for each day's bar (e.g. "Day 3: 6 200 steps")

- [x] StreakWidget: Convert `Metric` to `enum Metric: String, CaseIterable` and sync with AppIntent options
- [x] StreakWidget: Off-load heavy streak evaluation to background actor when metrics expand

### Cross-cutting / Shared Infrastructure
- [x] De-duplicate UI components (`MetricRow`, `StatItem`, `LegendItem`) by reusing `Shared/WidgetComponents.swift`
- [ ] Localise all hard-coded strings; wrap in `LocalizedStringKey`
- [ ] Add dark-mode snapshots to widget previews (`.environment(\.colorScheme, .dark)`)
- [ ] Document refresh cadence rationale in each TimelineProvider
- [ ] Consolidate HealthKit queries into a single aggregated call inside `HealthKitProvider`
- [ ] Add XCTest target with unit tests (e.g. `StreakEngine.evaluate` edge cases)
- [ ] Ensure semantic colours adapt in light/dark modes across widgets