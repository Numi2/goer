import HealthKit

/// A high-level metric that users can track as part of their daily health goals.
/// Today the only supported metric is **steps**, but the enum is future-proof and
/// Codable so more cases can be added without migrating existing data.
enum Metric: String, CaseIterable, Codable, Hashable {
    case steps

    /// The matching HealthKit quantity type for the metric.
    var quantityType: HKQuantityType {
        switch self {
        case .steps:
            return HKQuantityType.quantityType(forIdentifier: .stepCount)!
        }
    }

    /// A display name that is localised and appropriate for UI use.
    var displayName: String {
        switch self {
        case .steps: return "Steps"
        }
    }
}

// MARK: - LosslessStringConvertible

extension Metric: LosslessStringConvertible {
    init?(_ description: String) {
        self.init(rawValue: description)
    }

    var description: String { rawValue }
}

// MARK: - AppIntents enum helper

#if canImport(AppIntents)
import AppIntents

@available(iOS 17.0, macOS 14.0, *)
enum MetricAppEnum: String, AppEnum, CaseIterable {
    case steps

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Metric")

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .steps: DisplayRepresentation(title: "Steps")
    ]
}
#endif
