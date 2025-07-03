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
            // Basic activity metrics
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.appleStandTime),
            
            // Health metrics
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.bodyTemperature),
            HKQuantityType(.bloodPressureSystolic),
            HKQuantityType(.bloodPressureDiastolic),
            
            // Activity summaries
            HKObjectType.activitySummaryType()
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Aggregated Totals Helper
    /// Fetches both **steps** and **distance** totals for the given date range
    /// in parallel so that callers do not have to duplicate the two individual
    /// queries.
    private func fetchTotals(from startDate: Date, to endDate: Date) async throws -> (steps: Double, distance: Double) {
        async let steps = fetchSteps(from: startDate, to: endDate)
        async let distance = fetchDistance(from: startDate, to: endDate)
        return try await (steps: steps, distance: distance)
    }
    
    // MARK: - Daily Summary Data
    func fetchDailySummary() async throws -> DailySummaryModel {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        
        let (totalSteps, totalDistance) = try await fetchTotals(from: startOfDay, to: endOfDay)
        
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
        
        // Fetch aggregated totals once
        let (daySteps, dayDistance) = try await fetchTotals(from: startOfDay, to: endOfDay)
        
        // Fetch hourly breakdown (runs concurrently with totals above)
        let hourlySteps = try await fetchHourlySteps(for: startOfDay)
        
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
    
    private func fetchHourlySteps(for date: Date) async throws -> [Double] {
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
                
                var hourlySteps: [Double] = Array(repeating: 0, count: 24)
                
                collection?.enumerateStatistics(from: startOfDay, to: endOfDay) { statistics, _ in
                    let hour = calendar.component(.hour, from: statistics.startDate)
                    let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    if hour < 24 {
                        hourlySteps[hour] = steps
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
    
    // MARK: - Energy Metrics
    
    private func fetchActiveEnergy(from startDate: Date, to endDate: Date) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let energyType = HKQuantityType(.activeEnergyBurned)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let energy = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                continuation.resume(returning: energy)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchBasalEnergy(from startDate: Date, to endDate: Date) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let energyType = HKQuantityType(.basalEnergyBurned)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let energy = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                continuation.resume(returning: energy)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchExerciseMinutes(from startDate: Date, to endDate: Date) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let exerciseType = HKQuantityType(.appleExerciseTime)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: exerciseType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let minutes = result?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0
                continuation.resume(returning: minutes)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchStandHours(from startDate: Date, to endDate: Date) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let standType = HKQuantityType(.appleStandTime)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: standType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let hours = result?.sumQuantity()?.doubleValue(for: HKUnit.hour()) ?? 0
                continuation.resume(returning: hours)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Health Metrics
    
    private func fetchLatestHeartRate() async -> Double? {
        return await withCheckedContinuation { continuation in
            let heartRateType = HKQuantityType(.heartRate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching heart rate: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                if let sample = samples?.first as? HKQuantitySample {
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    continuation.resume(returning: heartRate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestHeartRateVariability() async -> Double? {
        return await withCheckedContinuation { continuation in
            let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(
                sampleType: hrvType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching HRV: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                if let sample = samples?.first as? HKQuantitySample {
                    let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    continuation.resume(returning: hrv)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestOxygenSaturation() async -> Double? {
        return await withCheckedContinuation { continuation in
            let spo2Type = HKQuantityType(.oxygenSaturation)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(
                sampleType: spo2Type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching oxygen saturation: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                if let sample = samples?.first as? HKQuantitySample {
                    let spo2 = sample.quantity.doubleValue(for: HKUnit.percent()) * 100
                    continuation.resume(returning: spo2)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestBodyTemperature() async -> Double? {
        return await withCheckedContinuation { continuation in
            let tempType = HKQuantityType(.bodyTemperature)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(
                sampleType: tempType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching body temperature: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                if let sample = samples?.first as? HKQuantitySample {
                    let temp = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
                    continuation.resume(returning: temp)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestBloodPressure() async -> (systolic: Double, diastolic: Double)? {
        return await withCheckedContinuation { continuation in
            let systolicType = HKQuantityType(.bloodPressureSystolic)
            let diastolicType = HKQuantityType(.bloodPressureDiastolic)
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // Fetch systolic first
            let systolicQuery = HKSampleQuery(
                sampleType: systolicType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching systolic BP: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let systolicSample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let systolic = systolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                
                // Now fetch diastolic
                let diastolicQuery = HKSampleQuery(
                    sampleType: diastolicType,
                    predicate: nil,
                    limit: 1,
                    sortDescriptors: [sortDescriptor]
                ) { _, samples, error in
                    if let error = error {
                        print("Error fetching diastolic BP: \(error)")
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    if let diastolicSample = samples?.first as? HKQuantitySample {
                        let diastolic = diastolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        continuation.resume(returning: (systolic: systolic, diastolic: diastolic))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
                
                self.healthStore.execute(diastolicQuery)
            }
            
            healthStore.execute(systolicQuery)
        }
    }
}
