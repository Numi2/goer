# Goer – Simple Distance Tracking App

Simple, clean distance tracking app that passively monitors your daily walking distance without requiring manual workout sessions.

---

## Table of Contents
1. [Features](#features)
2. [Requirements](#requirements)
3. [Getting Started](#getting-started)
4. [Project Structure](#project-structure)
5. [Using the App](#using-the-app)
6. [Distance Widget](#distance-widget)
7. [Architecture Overview](#architecture-overview)
8. [License](#license)

---

## Features

### Simple Distance Tracking
* **Today's Distance**: Large, clear display of your daily walking distance
* **Passive Monitoring**: No manual workout start required - tracks automatically
* **Clean Interface**: Minimal design focused on distance only
* **History View**: See your distance for each day in a simple list

### Distance Widget
* **Simple Widget**: Shows only today's distance in clear, readable text
* **Green Theme**: Consistent green color for location/distance theme
* **15-minute Refresh**: Efficient battery usage with regular updates
* **Small & Medium Sizes**: Available in both widget sizes

### Technical Highlights
* **StepTracker** passively monitors distance without workout sessions
* **HealthKitProvider** handles HealthKit data access
* Clean, simplified codebase with unnecessary complexity removed
* Swift 5.9, SwiftUI, `@Observable` model types

---

## Requirements
* **Xcode 16** or later
* **iOS 18** SDK or later
* A physical **iPhone or iPad** to test HealthKit integration and widgets
* A valid Apple Developer Team to enable HealthKit entitlements

---

## Getting Started

1. Clone the repository and open `WorkoutsOniOSSampleApp.xcodeproj` with Xcode
2. Set your developer team in *Signing & Capabilities* for both App and Widget targets
3. Connect an iOS device and **Build & Run** (`⌘R`)
4. Grant **HealthKit permissions** when prompted
5. (Optional) Add the Distance widget from the Home Screen widget gallery

---

## Project Structure

```
.
├─ WorkoutsOniOSSampleApp/     # Main SwiftUI app
│  ├─ Views/                   # Simple distance UI
│  │  └─ ActivityDashboardView.swift  # Main distance view
│  ├─ WorkoutsOniOSSampleApp.swift    # App entry point
│  └─ …
├─ Shared/                     # Shared utilities
│  ├─ HealthKitProvider.swift  # HealthKit data access
│  ├─ StepTracker.swift        # Passive distance monitoring
│  └─ StepTrackingModel.swift  # Data models
└─ WorkoutWidget/              # Simple distance widget
   ├─ DistanceWidget.swift     # Widget implementation
   └─ DistanceWidgetBundle.swift  # Widget bundle
```

---

## Using the App
1. **Open the app** - No setup required, distance tracking is automatic
2. **View today's distance** on the main screen in large, clear text
3. **Check history** in the History tab to see distance for each day
4. **Add the widget** to your home screen for quick distance glance

> All distance data comes from HealthKit and respects your privacy settings.

---

## Distance Widget

Simple widget implementation:

* Shows only today's walking distance
* Updates every 15 minutes for efficiency
* Green location icon for consistent theming
* Clean, readable design with large text

---

## Architecture Overview

Simple, clean architecture focused on distance tracking:

```
┌──────────────┐      distance data    ┌──────────────┐
│ HealthKit    │◀──────────────────── │ HealthKit    │
│ Store        │                      │ Provider     │
└──────────────┘                      └──────┬───────┘
                                             │ 
                                             ▼
                                   ┌───────────────────┐  observes  ┌────────────┐
                                   │ StepTracker       │──────────▶ │ SwiftUI    │
                                   └───────────────────┘   @Observable│ Views      │
                                                                     └─────┬──────┘
                                                                           │ 
                                                                           ▼
                                                                   ┌────────────┐
                                                                   │ Distance   │
                                                                   │ Widget     │
                                                                   └────────────┘
```

* `HealthKitProvider` fetches distance data from HealthKit
* `StepTracker` polls every 5 minutes and publishes distance updates
* SwiftUI views display distance with `@Observable` pattern
* Simple distance widget shows today's distance

---

## License
This sample is provided for **educational purposes only** under the terms of the Apple Sample Code License.
