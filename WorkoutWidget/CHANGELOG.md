# Distance Widget – Changelog

Simple distance tracking widget with no unnecessary complexity.

---

## Version 2.0.0 – 2025 (Simplified)

### 🎯 Major Simplification

* **Complete Redesign**: Simplified from complex workout app to simple distance tracker
  * Shows only daily walking distance in large, clear text
  * Clean interface with green location icon
  * No goals, no complex metrics, no workouts required

### Added

* `DistanceWidget.swift` – Simple widget showing only today's distance
* Passive distance monitoring using existing StepTracker

### Removed

* **All Complex Widgets**: Removed Streak, Hourly, Monthly, and Live Activity widgets
* **Workout Features**: Removed all workout management and session tracking
* **Complex Data**: Removed steps, energy, heart rate, and goal tracking
* **Advanced Features**: Removed streaks, analytics, and motivational messages

### Technical Changes

* Uses simple `HealthKitProvider.shared.fetchDailySummary()` for distance data
* 15-minute update intervals for battery efficiency
* Clean, minimal codebase with unnecessary complexity removed

---

Previous versions contained complex features that have been simplified away.
