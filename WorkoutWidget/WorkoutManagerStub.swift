#if !canImport(HealthKit)
import Foundation

/// A lightweight stub that satisfies references to `WorkoutManager` inside targets
/// (such as the widget extension) that don’t have access to the full workout engine
/// found in the main application.
///
/// The real `WorkoutManager` lives in the main app where HealthKit is available.
/// By wrapping this shim in `#if !canImport(HealthKit)`, we ensure there is only
/// one `WorkoutManager` definition per target, avoiding duplicate‐symbol errors.
final class WorkoutManager {
    static let shared = WorkoutManager()
    private init() {}

    /// The widget only needs to read / toggle this flag so keep it simple.
    var isLiveActivityActive: Bool = false
}
#endif
