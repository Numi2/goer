/*
Abstract:
`ActivityMonitor` passively observes the user's comprehensive health metrics
using HealthKit and exposes them to SwiftUI views. Unlike the existing
`WorkoutManager`, it doesn't require the user to start an explicit workout –
the monitor simply queries HealthKit on a schedule and publishes the results.
This follows the StepTracker pattern but expands to comprehensive health monitoring.
*/

import Foundation
import HealthKit
import os

@MainActor
@Observable
final class ActivityMonitor {
    // MARK: - Public published state
    private(set) var currentActivity: ActivitySummaryModel? = nil
    private(set) var healthMetrics: HealthMetricsModel? = nil
    private(set) var isMonitoring: Bool = false
    private(set) var lastUpdateTime: Date? = nil
    
    // MARK: - Private properties
    private var monitoringTask: Task<Void, Never>? = nil
    private let monitoringInterval: TimeInterval = 5 * 60 // 5-minute refresh
    private let logger = Logger(subsystem: "com.goer.activity", category: "ActivityMonitor")
    
    // Singleton pattern for shared access
    static let shared = ActivityMonitor()
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Manually refresh all activity data
    func refresh() {
        logger.info("Manual refresh requested")
        Task { 
            await fetchAllActivityData()
        }
    }
    
    /// Start passive monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        logger.info("Starting activity monitoring")
        isMonitoring = true
        
        monitoringTask = Task { [weak self] in
            // Request HealthKit authorization once
            do {
                try await HealthKitProvider.shared.requestAuthorization()
                logger.info("HealthKit authorization completed")
            } catch {
                logger.error("HealthKit authorization failed: \(error.localizedDescription)")
            }
            
            // Continuous monitoring loop
            while !Task.isCancelled {
                await self?.fetchAllActivityData()
                
                // Wait for next interval
                do {
                    try await Task.sleep(for: .seconds(self?.monitoringInterval ?? 300))
                } catch {
                    // Task was cancelled
                    break
                }
            }
            
            await MainActor.run {
                self?.isMonitoring = false
            }
        }
    }
    
    /// Stop passive monitoring
    func stopMonitoring() {
        logger.info("Stopping activity monitoring")
        monitoringTask?.cancel()
        monitoringTask = nil
        isMonitoring = false
    }
    
    // MARK: - Private Methods
    
    private func fetchAllActivityData() async {
        logger.debug("Fetching all activity data")
        
        do {
            // Fetch current activity summary and health metrics in parallel
            async let activitySummary = HealthKitProvider.shared.fetchActivitySummary()
            async let healthMetrics = HealthKitProvider.shared.fetchHealthMetrics()
            
            let summary = try await activitySummary
            let metrics = try await healthMetrics
            
            // Update published state
            self.currentActivity = summary
            self.healthMetrics = metrics
            self.lastUpdateTime = Date()
            
            logger.debug("Successfully updated activity data")
            
        } catch {
            logger.error("Failed to fetch activity data: \(error.localizedDescription)")
            // Keep existing data on error, just log it
        }
    }
}

// MARK: - Activity Summary Model

/// Comprehensive daily activity summary
struct ActivitySummaryModel: Codable, Hashable {
    let date: Date
    let steps: Int
    let distance: Double // in meters
    let activeEnergy: Double // in kilocalories
    let basalEnergy: Double // in kilocalories
    let activeMinutes: Int
    let standHours: Int
    let exerciseMinutes: Int
    
    // Goals (can be customized later)
    let stepGoal: Int
    let activeEnergyGoal: Double
    let exerciseGoal: Int
    let standGoal: Int
    
    // MARK: - Computed Properties
    
    var totalEnergy: Double {
        activeEnergy + basalEnergy
    }
    
    var stepProgress: Double {
        min(Double(steps) / Double(stepGoal), 1.0)
    }
    
    var activeEnergyProgress: Double {
        min(activeEnergy / activeEnergyGoal, 1.0)
    }
    
    var exerciseProgress: Double {
        min(Double(exerciseMinutes) / Double(exerciseGoal), 1.0)
    }
    
    var standProgress: Double {
        min(Double(standHours) / Double(standGoal), 1.0)
    }
    
    var activityLevel: ActivityLevel {
        let totalProgress = (stepProgress + activeEnergyProgress + exerciseProgress + standProgress) / 4.0
        
        switch totalProgress {
        case 0..<0.25:
            return .sedentary
        case 0.25..<0.5:
            return .lightlyActive
        case 0.5..<0.75:
            return .moderatelyActive
        case 0.75..<1.0:
            return .active
        default:
            return .veryActive
        }
    }
    
    // MARK: - Formatted Values
    
    var formattedSteps: String {
        NumberFormatter.stepFormatter.string(from: NSNumber(value: steps)) ?? "0"
    }
    
    var formattedDistance: String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
    
    var formattedActiveEnergy: String {
        let measurement = Measurement(value: activeEnergy, unit: UnitEnergy.kilocalories)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .workout))
    }
    
    var formattedTotalEnergy: String {
        let measurement = Measurement(value: totalEnergy, unit: UnitEnergy.kilocalories)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .workout))
    }
    
    var motivationalMessage: String {
        switch activityLevel {
        case .sedentary:
            return "Time to get moving! 🚶‍♀️"
        case .lightlyActive:
            return "Good start! Keep building momentum 👍"
        case .moderatelyActive:
            return "Great progress! You're doing well 🎯"
        case .active:
            return "Excellent work! Almost there 💪"
        case .veryActive:
            return "Amazing! You're crushing it! 🔥"
        }
    }
}

// MARK: - Health Metrics Model

/// Real-time health metrics
struct HealthMetricsModel: Codable, Hashable {
    let date: Date
    let heartRate: Double? // BPM
    let heartRateVariability: Double? // ms
    let oxygenSaturation: Double? // percentage
    let bodyTemperature: Double? // Celsius
    let bloodPressureSystolic: Double? // mmHg
    let bloodPressureDiastolic: Double? // mmHg
    
    // MARK: - Computed Properties
    
    var hasHeartRateData: Bool {
        heartRate != nil
    }
    
    var hasVitalSigns: Bool {
        heartRate != nil || oxygenSaturation != nil || bodyTemperature != nil
    }
    
    var heartRateCategory: HeartRateCategory {
        guard let hr = heartRate else { return .unknown }
        
        switch hr {
        case 0..<60:
            return .low
        case 60..<100:
            return .normal
        case 100..<120:
            return .elevated
        default:
            return .high
        }
    }
    
    // MARK: - Formatted Values
    
    var formattedHeartRate: String {
        guard let hr = heartRate else { return "--" }
        return "\(Int(hr.rounded()))"
    }
    
    var formattedHeartRateVariability: String {
        guard let hrv = heartRateVariability else { return "--" }
        return "\(Int(hrv.rounded()))"
    }
    
    var formattedOxygenSaturation: String {
        guard let spo2 = oxygenSaturation else { return "--" }
        return "\(Int(spo2.rounded()))"
    }
    
    var formattedBodyTemperature: String {
        guard let temp = bodyTemperature else { return "--" }
        return String(format: "%.1f", temp)
    }
}

// MARK: - Supporting Enums

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case active = "Active"
    case veryActive = "Very Active"
    
    var color: Color {
        switch self {
        case .sedentary: return .red
        case .lightlyActive: return .orange
        case .moderatelyActive: return .yellow
        case .active: return .green
        case .veryActive: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .sedentary: return "figure.seated.seatbelt"
        case .lightlyActive: return "figure.walk"
        case .moderatelyActive: return "figure.walk.motion"
        case .active: return "figure.run"
        case .veryActive: return "figure.run.motion"
        }
    }
}

enum HeartRateCategory: String, CaseIterable, Codable {
    case unknown = "Unknown"
    case low = "Low"
    case normal = "Normal"
    case elevated = "Elevated"
    case high = "High"
    
    var color: Color {
        switch self {
        case .unknown: return .gray
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .high: return .red
        }
    }
}

// MARK: - Extensions

extension NumberFormatter {
    static let stepFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

import SwiftUI

extension Color {
    static let activityColors = [
        Color.red,
        Color.orange,
        Color.yellow,
        Color.green,
        Color.blue
    ]
}