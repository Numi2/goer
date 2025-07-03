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
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced Header
            LiquidWidgetHeader(
                icon: "chart.bar.fill",
                iconColor: Color.accentColor,
                title: entry.data.dateTitle,
                subtitle: "Hourly Steps",
                variant: .expanded
            )
            
            // Enhanced summary stats
            HStack(spacing: 12) {
                LiquidStatCard(
                    title: "Steps",
                    value: entry.data.formattedTotalSteps,
                    color: .blue,
                    size: .medium,
                    variant: .glass
                )
                
                LiquidStatCard(
                    title: "Distance",
                    value: entry.data.formattedTotalDistance,
                    color: .green,
                    size: .medium,
                    variant: .glass
                )
            }
            
            // Enhanced bar chart with liquid effects
            EnhancedHourlyBarChart(data: entry.data.hourlySteps)
            
            // Enhanced timestamp with subtle glass effect
            Text("Data as of \(entry.date.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .quickGlass(tint: .gray, intensity: 0.3)
        }
        .padding()
        .enhancedGlassCard(
            variant: .regular,
            intensity: 1.0,
            enableMorph: true,
            tint: Color.accentColor
        )
        .dynamicLiquidBackground(
            colors: [
                Color.orange.opacity(0.2),
                Color.accentColor.opacity(0.1),
                Color.blue.opacity(0.05)
            ],
            intensity: 0.7
        )
    }
}

// MARK: - Enhanced Hourly Bar Chart Component
private struct EnhancedHourlyBarChart: View {
    let data: [Double]
    @State private var hoveredBar: Int? = nil
    
    var maxValue: Double {
        data.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Chart with enhanced liquid bars
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<min(data.count, 24), id: \.self) { hour in
                    LiquidChartBar(
                        value: data[hour],
                        maxValue: maxValue,
                        color: barColor(for: hour),
                        style: .liquid,
                        isActive: hoveredBar == hour
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            hoveredBar = hoveredBar == hour ? nil : hour
                        }
                    }
                }
            }
            .frame(height: 60)
            
            // Enhanced time labels with glass background
            HStack {
                ForEach([0,6,12,18,24], id: \.self) { hour in
                    Text(Self.label(for: hour))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .quickGlass(tint: .clear, intensity: 0.4)
                    if hour != 24 { Spacer() }
                }
            }
        }
        .padding(.horizontal, 4)
        .quickGlass(
            tint: Color.accentColor,
            intensity: 0.5,
            interactive: false
        )
    }
    
    private func barColor(for hour: Int) -> Color {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        if hour == currentHour {
            return .orange
        } else if hour < currentHour {
            return Color.accentColor
        } else {
            return Color.accentColor.opacity(0.6)
        }
    }
    
    private static func label(for hour: Int) -> String {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        guard let date = calendar.date(byAdding: .hour, value: hour % 24, to: baseDate) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: formatter.locale)
        return formatter.string(from: date)
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
