# Project Overview

This repository contains an example iOS application named **Goer** that demonstrates tracking workouts with HealthKit and presenting information using a Widget / Live Activity. The code is organised into several top-level folders:

- `Shared`: SwiftUI components that are reused across the app and the widget.
- `WorkoutWidget`: Implementation of the Live Activity widget.
- `WorkoutsOniOSSampleApp`: The main iOS application.
- `Configuration`: Xcode build configuration file.
- `WorkoutsOniOSSampleApp.xcodeproj`: Xcode project settings.

Below is an explanation of each file and how the pieces fit together.

## Shared

### `ElapsedTimeView.swift`
Displays the workout's elapsed time using a custom formatter.

### `MetricsModel.swift`
Model object that stores metrics such as heart rate, active energy, distance, and speed. It also provides helper methods to format those values for display.

## WorkoutWidget

### `WorkoutWidgetBundle.swift`
Declares the widget bundle entry point and registers the Live Activity widget.

### `WorkoutWidgetLiveActivity.swift`
Defines the Live Activity configuration using `ActivityConfiguration` and sets up the dynamic island views.

### `LiveActivityView.swift`
SwiftUI view presented inside the Live Activity to show metrics like elapsed time, heart rate and energy.

### `WorkoutWidgetViewModel.swift`
`Observable` class that manages creating, updating and ending the Live Activity instance.

### `WorkoutWidgetsAttributes.swift`
`ActivityAttributes` type describing the fixed and dynamic state values used by the Live Activity.

### Assets & `Info.plist`
Images and widget configuration for the Live Activity target.

## WorkoutsOniOSSampleApp

### `CountDownManager.swift`
Handles a short countdown before starting a workout session.

### `HKWorkout+HKWorkoutConfiguration.swift`
Extension on `HKWorkout` to create the related `HKWorkoutConfiguration` object.

### `NavigationModel.swift`
`Observable` model that drives app navigation between the start view, countdown, active session and summary views.

### `WorkoutManager.swift`
Main controller that manages HealthKit sessions, collects workout metrics and communicates with the widget model. It requests HealthKit authorisation, starts/ends workouts and updates metrics as samples arrive.

### `WorkoutTypes.swift`
Utility helpers to describe supported workout types and provide convenience properties like name, symbol and whether a workout supports distance or speed metrics.

### `WorkoutsOniOSSampleApp.swift`
SwiftUI `App` entry point. It initialises the navigation model and hosts the different views depending on the workout state.

### `WorkoutsOniOSSampleAppDelegate.swift`
`UIApplicationDelegate` implementation used for workout recovery and intent handling integration.

### `WorkoutsOniOSSampleAppSceneDelegate.swift`
Minimal `UIWindowSceneDelegate` required to support the app delegate's scene configuration method.

### `Intent/IntentHandler.swift`
Implements Siri workout intents so workouts can be started, paused, resumed and ended via Siri or App Intents.

### Views
- `ControlsView.swift` – start/stop/pause buttons during a session.
- `CountDownView.swift` – shows the pre‑workout countdown animation.
- `MetricsView.swift` – displays metrics while the workout is running using a `TimelineView`.
- `SessionView.swift` – combines the metrics and controls into a single screen.
- `StartView.swift` – lets the user pick a workout type and request HealthKit authorisation.
- `SummaryView.swift` – shows results after the workout finishes.

### `WorkoutsOniOSSampleApp.entitlements`
Entitlements enabling HealthKit and Siri support.

### `Info.plist`
Application configuration used by iOS.

### `Assets.xcassets` and `Preview Content`
App icon, preview assets and related resources.

## Configuration

### `SampleCode.xcconfig`
Xcode configuration file containing sample code settings.

## Xcode Project
The `WorkoutsOniOSSampleApp.xcodeproj` folder holds the Xcode project and scheme used to build both the app and the widget targets.

## How it Works
1. **StartView** presents a list of workout types. Selecting one sets up a `HKWorkoutConfiguration` on the `WorkoutManager`.
2. The `WorkoutManager` prepares a session and the `NavigationModel` transitions to `CountDownView`.
3. When the countdown completes, `WorkoutManager` starts the workout, begins collecting HealthKit metrics and launches a Live Activity via `WorkoutWidgetViewModel`.
4. `SessionView` displays current metrics while the Live Activity mirrors the same information on the Lock Screen or Dynamic Island.
5. When the user stops the workout, metrics are finalised and `SummaryView` presents the results.
6. The Live Activity is ended and eventually dismissed.

This overview should help future contributors understand where functionality lives and how the files work together.
