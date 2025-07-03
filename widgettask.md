- [ ] DailySummaryWidget: Replace `MetricRow` with shared `MetricDisplay` component
- [ ] DailySummaryWidget: Move hard-coded orange accent colour to semantic colour asset
- [ ] DailySummaryWidget: Add `.accessibilityLabel` to motivational message

- [ ] HourlyStepsWidget: Reconsider 1-minute refresh; document WidgetKit throttling or relax to 15 minutes
- [ ] HourlyStepsWidget: Change `hourlySteps` values to `Double` for future metrics
- [ ] HourlyStepsWidget: Generate time-axis labels with `DateFormatter` respecting locale
- [ ] HourlyStepsWidget: (Optional) Add "data as of…" caption if real-time accuracy is important

- [ ] MonthlyStepsWidget: Use `daysInMonth` to iterate, avoiding unused views in shorter months
- [ ] MonthlyStepsWidget: Extract goal-day threshold (8 000 steps) to constant or user setting
- [ ] MonthlyStepsWidget: Add accessibility labels for each day's bar (e.g. "Day 3: 6 200 steps")

- [ ] StreakWidget: Convert `Metric` to `enum Metric: String, CaseIterable` and sync with AppIntent options
- [ ] StreakWidget: Off-load heavy streak evaluation to background actor when metrics expand

### Cross-cutting / Shared Infrastructure
- [ ] De-duplicate UI components (`MetricRow`, `StatItem`, `LegendItem`) by reusing `Shared/WidgetComponents.swift`
- [ ] Localise all hard-coded strings; wrap in `LocalizedStringKey`
- [ ] Add dark-mode snapshots to widget previews (`.environment(\.colorScheme, .dark)`)
- [ ] Document refresh cadence rationale in each TimelineProvider
- [ ] Consolidate HealthKit queries into a single aggregated call inside `HealthKitProvider`
- [ ] Add XCTest target with unit tests (e.g. `StreakEngine.evaluate` edge cases)
- [ ] Ensure semantic colours adapt in light/dark modes across widgets