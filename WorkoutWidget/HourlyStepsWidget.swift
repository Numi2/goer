/*
Abstract:
Hourly Steps Widget showing 24-hour step bar chart with orange bars.
Updates every minute following Apple's Liquid Glass design principles.
*/

import SwiftUI
import WidgetKit

struct HourlyStepsWidget: Widget {
    let kind: String = "HourlyStepsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HourlyStepsProvider()) { entry in
            HourlyStepsView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Hourly Steps")
        .description("View your steps broken down by hour with a detailed bar chart.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Provider
struct HourlyStepsProvider: TimelineProvider {
    func placeholder(in context: Context) -> HourlyStepsEntry {
        HourlyStepsEntry(
            date: Date(),
            data: HourlyStepsModel(
                date: Date(),
                totalSteps: 12450,
                totalDistance: 8400,
                hourlySteps: Array(repeating: 0, count: 24).enumerated().map { index, _ in
                    Int.random(in: 0...800)
                }
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HourlyStepsEntry) -> ()) {
        let entry = HourlyStepsEntry(
            date: Date(),
            data: HourlyStepsModel(
                date: Date(),
                totalSteps: 12450,
                totalDistance: 8400,
                hourlySteps: Array(repeating: 0, count: 24).enumerated().map { index, _ in
                    Int.random(in: 0...800)
                }
            )
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<HourlyStepsEntry>) -> ()) {
        Task { @MainActor in
            let timeline: Timeline<HourlyStepsEntry>
            do {
                let data = try await HealthKitProvider.shared.fetchHourlyData()
                let entry = HourlyStepsEntry(date: Date(), data: data)
                
                // Update every minute as requested
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            } catch {
                // Fallback entry on error
                let fallbackEntry = HourlyStepsEntry(
                    date: Date(),
                    data: HourlyStepsModel(
                        date: Date(),
                        totalSteps: 0,
                        totalDistance: 0,
                        hourlySteps: Array(repeating: 0, count: 24)
                    )
                )
                timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(60)))
            }
            completion(timeline)
        }
    }
}

// MARK: - Entry
struct HourlyStepsEntry: TimelineEntry {
    let date: Date
    let data: HourlyStepsModel
}

// MARK: - View
struct HourlyStepsView: View {
    let entry: HourlyStepsEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(.orange.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.data.dateTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Hourly Steps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Summary stats
            HStack(spacing: 16) {
                StatItem(
                    title: "Steps",
                    value: entry.data.formattedTotalSteps,
                    color: .blue
                )
                
                StatItem(
                    title: "Distance",
                    value: entry.data.formattedTotalDistance,
                    color: .green
                )
            }
            
            // Bar chart
            HourlyBarChart(data: entry.data.hourlySteps)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Item Component
private struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Hourly Bar Chart Component
private struct HourlyBarChart: View {
    let data: [Int]
    
    var maxValue: Int {
        data.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Chart
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<min(data.count, 24), id: \.self) { hour in
                    BarView(
                        value: data[hour],
                        maxValue: maxValue,
                        hour: hour
                    )
                }
            }
            .frame(height: 60)
            
            // Time labels
            HStack {
                Text("12A")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Text("6A")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Text("12P")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Text("6P")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Text("12A")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Bar View Component
private struct BarView: View {
    let value: Int
    let maxValue: Int
    let hour: Int
    
    private var normalizedHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(value) / CGFloat(maxValue)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.orange.gradient)
            .frame(height: max(2, normalizedHeight * 60))
            .frame(maxWidth: .infinity)
            .opacity(value > 0 ? 1.0 : 0.3)
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    HourlyStepsWidget()
} timeline: {
    HourlyStepsEntry(
        date: Date(),
        data: HourlyStepsModel(
            date: Date(),
            totalSteps: 12450,
            totalDistance: 8400,
            hourlySteps: [120, 340, 156, 78, 245, 890, 1200, 1450, 987, 1123, 1890, 1567, 1234, 1678, 1345, 1890, 1456, 1234, 1567, 1123, 890, 678, 345, 123]
        )
    )
}
