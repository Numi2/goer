/*
Abstract:
Data models for step tracking widgets following liquid glass design principles.
*/

import Foundation
import HealthKit

// MARK: - Daily Summary Model
struct DailySummaryModel: Codable, Hashable {
    let stepsToday: Int
    let distanceToday: Double // in meters
    let date: Date
    
    var formattedSteps: String {
        NumberFormatter.stepFormatter.string(from: NSNumber(value: stepsToday)) ?? "0"
    }
    
    var formattedDistance: String {
        let measurement = Measurement(value: distanceToday, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
    
    var motivationalMessage: String {
        switch stepsToday {
        case 0..<1000:
            return "Time to get moving! 🚶‍♀️"
        case 1000..<3000:
            return "Good start! Keep it up 👍"
        case 3000..<6000:
            return "Making great progress! 🎯"
        case 6000..<8000:
            return "Almost there! Push forward 💪"
        case 8000..<10000:
            return "Excellent work today! 🌟"
        case 10000..<15000:
            return "Crushing your goals! 🔥"
        default:
            return "Absolutely amazing! 🏆"
        }
    }
}

// MARK: - Hourly Steps Model
struct HourlyStepsModel: Codable, Hashable {
    let date: Date
    let totalSteps: Int
    let totalDistance: Double // in meters
    let hourlySteps: [Int] // 24 hour array
    
    var formattedTotalSteps: String {
        NumberFormatter.stepFormatter.string(from: NSNumber(value: totalSteps)) ?? "0"
    }
    
    var formattedTotalDistance: String {
        let measurement = Measurement(value: totalDistance, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
    
    var maxHourlySteps: Int {
        hourlySteps.max() ?? 1
    }
    
    var dateTitle: String {
        date.formatted(.dateTime.weekday(.wide).month().day())
    }
}

// MARK: - Monthly Steps Model
struct MonthlyStepsModel: Codable, Hashable {
    let month: Date
    let totalSteps: Int
    let totalDistance: Double // in meters
    let dailySteps: [Int] // Array of daily step counts for the month
    
    var formattedTotalSteps: String {
        NumberFormatter.stepFormatter.string(from: NSNumber(value: totalSteps)) ?? "0"
    }
    
    var formattedTotalDistance: String {
        let measurement = Measurement(value: totalDistance, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
    
    var monthTitle: String {
        month.formatted(.dateTime.month(.wide).year())
    }
    
    var maxDailySteps: Int {
        dailySteps.max() ?? 1
    }
    
    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 30
    }
}

// MARK: - Number Formatter Extension
extension NumberFormatter {
    static let stepFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}