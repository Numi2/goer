/*
Abstract:
HealthKit provider for fetching step and distance data for widgets.
*/

import Foundation
import HealthKit
import os

@MainActor
class HealthKitProvider: ObservableObject {
    static let shared = HealthKitProvider()
    
    private let healthStore = HKHealthStore()
    private let logger = Logger(subsystem: "com.goer.widgets", category: "HealthKitProvider")
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization() async throws {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning)
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Daily Summary Data
    func fetchDailySummary() async throws -> DailySummaryModel {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        
        async let steps = fetchSteps(from: startOfDay, to: endOfDay)
        async let distance = fetchDistance(from: startOfDay, to: endOfDay)
        
        let (totalSteps, totalDistance) = try await (steps, distance)
        
        return DailySummaryModel(
            stepsToday: Int(totalSteps),
            distanceToday: totalDistance,
            date: now
        )
    }
    
    // MARK: - Hourly Data
    func fetchHourlyData() async throws -> HourlyStepsModel {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        
        // Fetch total for the day
        async let totalSteps = fetchSteps(from: startOfDay, to: endOfDay)
        async let totalDistance = fetchDistance(from: startOfDay, to: endOfDay)
        
        // Fetch hourly breakdown
        let hourlySteps = try await fetchHourlySteps(for: startOfDay)
        
        let (daySteps, dayDistance) = try await (totalSteps, totalDistance)
        
        return HourlyStepsModel(
            date: now,
            totalSteps: Int(daySteps),
            totalDistance: dayDistance,
            hourlySteps: hourlySteps
        )
    }
    
    // MARK: - Monthly Data
    func fetchMonthlyData() async throws -> MonthlyStepsModel {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        // Fetch total for the month
        async let totalSteps = fetchSteps(from: startOfMonth, to: endOfMonth)
        async let totalDistance = fetchDistance(from: startOfMonth, to: endOfMonth)
        
        // Fetch daily breakdown
        let dailySteps = try await fetchDailySteps(for: startOfMonth)
        
        let (monthSteps, monthDistance) = try await (totalSteps, totalDistance)
        
        return MonthlyStepsModel(
            month: startOfMonth,
            totalSteps: Int(monthSteps),
            totalDistance: monthDistance,
            dailySteps: dailySteps
        )
    }
    
    // MARK: - Private Helper Methods
    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let stepType = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchDistance(from startDate: Date, to endDate: Date) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let distanceType = HKQuantityType(.distanceWalkingRunning)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let distance = result?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                continuation.resume(returning: distance)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchHourlySteps(for date: Date) async throws -> [Int] {
        return try await withCheckedThrowingContinuation { continuation in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let stepType = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            var interval = DateComponents()
            interval.hour = 1
            
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startOfDay,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, collection, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                var hourlySteps: [Int] = Array(repeating: 0, count: 24)
                
                collection?.enumerateStatistics(from: startOfDay, to: endOfDay) { statistics, _ in
                    let hour = calendar.component(.hour, from: statistics.startDate)
                    let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    if hour < 24 {
                        hourlySteps[hour] = Int(steps)
                    }
                }
                
                continuation.resume(returning: hourlySteps)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchDailySteps(for monthStart: Date) async throws -> [Int] {
        return try await withCheckedThrowingContinuation { continuation in
            let calendar = Calendar.current
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            
            let stepType = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(withStart: monthStart, end: monthEnd, options: .strictStartDate)
            
            var interval = DateComponents()
            interval.day = 1
            
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: monthStart,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, collection, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
                var dailySteps: [Int] = Array(repeating: 0, count: daysInMonth)
                
                collection?.enumerateStatistics(from: monthStart, to: monthEnd) { statistics, _ in
                    let day = calendar.component(.day, from: statistics.startDate) - 1
                    let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    if day < daysInMonth && day >= 0 {
                        dailySteps[day] = Int(steps)
                    }
                }
                
                continuation.resume(returning: dailySteps)
            }
            
            healthStore.execute(query)
        }
    }
}