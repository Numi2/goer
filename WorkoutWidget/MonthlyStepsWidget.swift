/*
Abstract:
Monthly Steps Widget showing daily step bar chart with green/orange color coding.
Green bars for days with 8000+ steps, orange for fewer. Updates hourly.
*/

import SwiftUI
import WidgetKit

struct MonthlyStepsWidget: Widget {
    let kind: String = "MonthlyStepsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MonthlyStepsProvider()) { entry in
            MonthlyStepsView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Monthly Steps")
        .description("Track your monthly step goals with a daily breakdown and progress indicators.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Provider
struct MonthlyStepsProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthlyStepsEntry {
        MonthlyStepsEntry(
            date: Date(),
            data: MonthlyStepsModel(
                month: Date(),
                totalSteps: 245678,
                totalDistance: 185400,
                dailySteps: Array(repeating: 0, count: 30).enumerated().map { index, _ in
                    Int.random(in: 2000...15000)
                }
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MonthlyStepsEntry) -> ()) {
        let entry = MonthlyStepsEntry(
            date: Date(),
            data: MonthlyStepsModel(
                month: Date(),
                totalSteps: 245678,
                totalDistance: 185400,
                dailySteps: Array(repeating: 0, count: 30).enumerated().map { index, _ in
                    Int.random(in: 2000...15000)
                }
            )
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<MonthlyStepsEntry>) -> ()) {
        Task { @MainActor in
            let timeline: Timeline<MonthlyStepsEntry>
            
            do {
                let data = try await HealthKitProvider.shared.fetchMonthlyData()
                let entry = MonthlyStepsEntry(date: Date(), data: data)
                
                // Update every hour.
                // Monthly progress changes less frequently; hourly refresh keeps data fresh without wasting the 4-hour default budget.
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            } catch {
                // Fallback entry on error
                let fallbackEntry = MonthlyStepsEntry(
                    date: Date(),
                    data: MonthlyStepsModel(
                        month: Date(),
                        totalSteps: 0,
                        totalDistance: 0,
                        dailySteps: Array(repeating: 0, count: 30)
                    )
                )
                timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(3600)))
            }
            
            completion(timeline)
        }
    }
}

// MARK: - Entry
struct MonthlyStepsEntry: TimelineEntry {
    let date: Date
    let data: MonthlyStepsModel
}

// MARK: - View
struct MonthlyStepsView: View {
    let entry: MonthlyStepsEntry
    
    private var goalDays: Int {
        entry.data.dailySteps.filter { $0 >= 8000 }.count
    }
    
    private var totalDays: Int {
        entry.data.daysInMonth
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.green)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(.green.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.data.monthTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Daily Steps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Summary stats
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Steps",
                    value: entry.data.formattedTotalSteps,
                    color: .blue
                )
                
                StatCard(
                    title: "Distance",
                    value: entry.data.formattedTotalDistance,
                    color: .green
                )
                
                StatCard(
                    title: "Goal Days",
                    value: "\(goalDays)/\(totalDays)",
                    color: goalDays >= totalDays * 2 / 3 ? .green : .orange
                )
            }
            
            // Monthly bar chart
            MonthlyBarChart(data: entry.data.dailySteps, daysInMonth: entry.data.daysInMonth)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Monthly Bar Chart Component
private struct MonthlyBarChart: View {
    let data: [Int]
    let daysInMonth: Int
    
    private let stepGoal = 8_000
    
    var maxValue: Int {
        data.prefix(daysInMonth).max() ?? 1
    }
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Chart
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<daysInMonth, id: \.self) { day in
                    MonthlyBarView(
                        value: data[day],
                        maxValue: maxValue,
                        day: day + 1,
                        stepGoal: stepGoal
                    )
                }
            }
            .frame(height: 80)
            
      
        }
    }
}

// MARK: - Monthly Bar View Component
private struct MonthlyBarView: View {
    let value: Int
    let maxValue: Int
    let day: Int
    let stepGoal: Int
    
    private var normalizedHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(value) / CGFloat(maxValue)
    }
    
    private var barColor: Color {
        value >= stepGoal ? .green : .orange
    }
    
    var body: some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(barColor.gradient)
                .frame(height: max(2, normalizedHeight * 60))
                .opacity(value > 0 ? 1.0 : 0.3)
                .accessibilityLabel("Day \(day): \(value.formatted()) steps")
            
            Text("\(day)")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    MonthlyStepsWidget()
} timeline: {
    MonthlyStepsEntry(
        date: Date(),
        data: MonthlyStepsModel(
            month: Date(),
            totalSteps: 245678,
            totalDistance: 185400,
            dailySteps: [12000, 8500, 6200, 9100, 11300, 7800, 13400, 9800, 10200, 8900, 7500, 12100, 9400, 8700, 10800, 9200, 8100, 11700, 9900, 8300, 7900, 10500, 9600, 8800, 11200, 9000, 8400, 10700, 9300, 8600, 7200]
        )
    )
}

#Preview("Dark", as: .systemMedium) {
    MonthlyStepsWidget()
} timeline: {
    MonthlyStepsEntry(
        date: Date(),
        data: MonthlyStepsModel(
            month: Date(),
            totalSteps: 245678,
            totalDistance: 185400,
            dailySteps: [12000, 8500, 6200, 9100, 11300, 7800, 13400, 9800, 10200, 8900, 7500, 12100, 9400, 8700, 10800, 9200, 8100, 11700, 9900, 8300, 7900, 10500, 9600, 8800, 11200, 9000, 8400, 10700, 9300, 8600, 7200]
        )
    )
}
