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
                hourlySteps: Array(repeating: 0, count: 24).enumerated().map { _, _ in
                    Double.random(in: 0...800)
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
                hourlySteps: Array(repeating: 0, count: 24).enumerated().map { _, _ in
                    Double.random(in: 0...800)
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
                
                // Update every 15 minutes.
                // Widgets with minute-level precision are likely throttled unless implemented as Live Activities.
                // This strikes a balance between timely stats and system resource constraints.
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
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
                    .foregroundStyle(.accentColor)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
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
                StatCard(
                    title: "Steps",
                    value: entry.data.formattedTotalSteps,
                    color: .blue
                )
                
                StatCard(
                    title: "Distance",
                    value: entry.data.formattedTotalDistance,
                    color: .green
                )
            }
            
            // Bar chart
            HourlyBarChart(data: entry.data.hourlySteps)
            
            // Optional timestamp caption for clarity when WidgetKit delays updates
            Text("Data as of \(entry.date.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Item Component
// Deprecated: replaced by shared `StatCard` (see `Shared/WidgetComponents.swift`).

// MARK: - Hourly Bar Chart Component
private struct HourlyBarChart: View {
    let data: [Double]
    
    var maxValue: Double {
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
                ForEach([0,6,12,18,24], id: \.self) { hour in
                    Text(Self.label(for: hour))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    if hour != 24 { Spacer() }
                }
            }
        }
    }
    
    private static func label(for hour: Int) -> String {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        guard let date = calendar.date(byAdding: .hour, value: hour % 24, to: baseDate) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: formatter.locale) // hour format respecting 12/24h
        return formatter.string(from: date)
    }
}

// MARK: - Bar View Component
private struct BarView: View {
    let value: Double
    let maxValue: Double
    let hour: Int
    
    private var normalizedHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(value / maxValue)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.accentColor.gradient)
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
            hourlySteps: [120, 340, 156, 78, 245, 890, 1200, 1450, 987, 1123, 1890, 1567, 1234, 1678, 1345, 1890, 1456, 1234, 1567, 1123, 890, 678, 345, 123].map(Double.init)
        )
    )
}

#Preview("Dark", as: .systemMedium) {
    HourlyStepsWidget()
        .environment(\.colorScheme, .dark)
} timeline: {
    HourlyStepsEntry(
        date: Date(),
        data: HourlyStepsModel(
            date: Date(),
            totalSteps: 12450,
            totalDistance: 8400,
            hourlySteps: [120, 340, 156, 78, 245, 890, 1200, 1450, 987, 1123, 1890, 1567, 1234, 1678, 1345, 1890, 1456, 1234, 1567, 1123, 890, 678, 345, 123].map(Double.init)
        )
    )
}
