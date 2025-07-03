# Goer – Workout & Steps Sample App for iPhone and iPad

Start, monitor, and complete workouts on-device while showcasing **HealthKit**, **Live Activities**, **App Intents**, and a suite of **SwiftUI widgets** built with Apple's liquid-glass design language.

> **WWDC25 Sample Code** – This project accompanies the session [Track workouts with HealthKit on iPhone and iPad](https://developer.apple.com/wwdc25/322/).

---

## Table of Contents
1. [Features](#features)
2. [Requirements](#requirements)
3. [Getting Started](#getting-started)
4. [Project Structure](#project-structure)
5. [Using the App](#using-the-app)
6. [Step-Tracking Widgets](#step-tracking-widgets)
7. [Architecture Overview](#architecture-overview)
8. [Contributing](#contributing)
9. [License](#license)

---

## Features

### Workout Experience
* One-tap start for **outdoor run, walk, hike, cycle, row, or gym** workouts.
* Real-time metrics (distance, pace, heart rate) surfaced via `WorkoutManager`.
* **Live Activity** keeps workout stats on the Lock Screen & Dynamic Island.
* Control the workout (pause / resume / end) directly from the Live Activity.

### Step-Tracking Widgets
| Widget | Sizes | Refresh | Description |
|---|---|---|---|
| **Daily Summary** | Small / Medium | 15 min | Steps & distance with motivational copy |
| **Hourly Steps** | Medium / Large | 1 min | 24-hour bar chart of step activity |
| **Monthly Steps** | Medium / Large | 1 hr | Calendar-style month view with goal colours |

> All widgets follow Apple's liquid-glass design guidance and support Light / Dark Mode, Dynamic Type, and VoiceOver.

### Additional Highlights
* **HealthKitProvider** centralises HealthKit queries & writes.
* **StepTracker** passively updates step totals without an active workout.
* **App Intents** expose workout actions to system UI & Shortcuts.
* Swift 5.9, SwiftUI, Concurrency, `@Observable` model types.

---

## Requirements
* **Xcode 16** or later (Xcode beta 2025 or newer).
* **iOS 18** SDK (or the SDK that shipped with WWDC25).
* A physical **iPhone or iPad** running iOS 18 to view Live Activities & widgets.
* A valid Apple Developer Team set on each target to enable HealthKit & ActivityKit entitlements.

---

## Getting Started

1. Clone the repository and open `WorkoutsOniOSSampleApp.xcodeproj` **with the latest Xcode**.
2. In the Project navigator, select **each target** (App, Widgets, Tests) and set *Signing & Capabilities → Team* to your developer team.
3. Connect an iOS device, select it as the run destination, then **Build & Run** (`⌘R`).
4. Grant **Health permissions** when prompted.
5. (Optional) Add any of the Goer widgets from the **Home Screen widget gallery**.

---

## Project Structure

```
.
├─ WorkoutsOniOSSampleApp/     # SwiftUI application & app life-cycle
│  ├─ Views/                   # Workout UI and navigation flow
│  ├─ WorkoutManager.swift     # HKWorkoutSession orchestration
│  └─ …
├─ Shared/                     # Cross-target models & utilities
│  ├─ HealthKitProvider.swift  # Reusable HealthKit helper
│  ├─ StepTracker.swift        # Passive step updates
│  └─ WidgetComponents.swift   # Common liquid-glass UI parts
├─ WorkoutWidget/              # WidgetKit bundle (4 widgets + Live Activity)
│  ├─ DailySummaryWidget.swift
│  ├─ HourlyStepsWidget.swift
│  ├─ MonthlyStepsWidget.swift
│  └─ WorkoutWidgetLiveActivity.swift
├─ WorkoutWidgetTests/         # Unit tests (e.g., `StreakEngineTests`)
└─ Documentation/              # Guides & design docs (e.g., `WIDGET_INTEGRATION_GUIDE.md`)
```

---

## Using the App
1. **Start** a workout on the main screen.
2. Monitor metrics inside the app **or** glance at the **Live Activity** on the Lock Screen.
3. **Pause / Resume / End** the session from the Live Activity or in-app controls.
4. Review your **step progress** throughout the day via widgets.

> All recorded workout data is written to HealthKit and can be viewed in the Apple Health app.

---

## Step-Tracking Widgets

For in-depth implementation details, see [`WIDGET_INTEGRATION_GUIDE.md`](./WIDGET_INTEGRATION_GUIDE.md). At a glance:

* Widgets fetch data via `HealthKitProvider.shared`.
* Timeline entries cache results to minimise queries & battery impact.
* Liquid-glass effects (`.ultraThinMaterial`) deliver depth & vibrancy.
* Each widget adapts its layout for available size classes and respects `ContentSizeCategory` and `Reduce Motion`.

---

## Architecture Overview

```
┌──────────────┐      publishes       ┌──────────────┐
│ HealthKit    │◀──────────────────── │ HealthKit    │
│ Store        │    metrics via       │ Provider     │
└──────────────┘                      └──────┬───────┘
                                             │ async/await
                                             ▼
                                   ┌───────────────────┐  observes  ┌────────────┐
                                   │ WorkoutManager    │──────────▶ │ SwiftUI    │
                                   └───────────────────┘   @Observable│ Views      │
                                            ▲                        └────────────┘
                                            │ updates                   ▲ widgets / live activities
                                            │                           │
                                   ┌───────────────────┐               │
                                   │ StepTracker       │───────────────┘
                                   └───────────────────┘
```

* `HealthKitProvider` executes **queries & writes**.
* `WorkoutManager` manages an `HKWorkoutSession` and publishes **real-time workout metrics**.
* `StepTracker` polls for **daily step totals** and feeds widgets.
* Widgets & Live Activities subscribe to state via a shared `WorkoutWidgetViewModel`.

---

## Contributing
Pull requests are welcome!

1. Fork the repo & create a feature branch.
2. Follow the existing code style (`swift-format` preferred).
3. Include unit tests where meaningful.
4. Open a PR — please describe **what** you changed and **why**.

---

## License
This sample is provided for **educational purposes only** under the terms of the Apple Sample Code License.
