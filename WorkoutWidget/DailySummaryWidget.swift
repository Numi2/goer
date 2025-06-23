/*
Abstract:
Daily Summary Widget showing today's steps and distance with motivational message.
Following Apple's Liquid Glass design principles.
*/

import SwiftUI
import WidgetKit

struct DailySummaryWidget: Widget {
    let kind: String = "DailySummaryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailySummaryProvider()) { entry in
            DailySummaryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Summary")
        .description("Track your daily steps and distance with motivational messages.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Provider
struct DailySummaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailySummaryEntry {
        DailySummaryEntry(
            date: Date(),
            data: DailySummaryModel(
                stepsToday: 6543,
                distanceToday: 4200,
                date: Date()
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailySummaryEntry) -> ()) {
        let entry = DailySummaryEntry(
            date: Date(),
            data: DailySummaryModel(
                stepsToday: 6543,
                distanceToday: 4200,
                date: Date()
            )
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<DailySummaryEntry>) -> ()) {
        Task { @MainActor in
            let timeline: Timeline<DailySummaryEntry>
            do {
                let data = try await HealthKitProvider.shared.fetchDailySummary()
                let entry = DailySummaryEntry(date: Date(), data: data)
                
                // Update every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            } catch {
                // Fallback entry on error
                let fallbackEntry = DailySummaryEntry(
                    date: Date(),
                    data: DailySummaryModel(
                        stepsToday: 0,
                        distanceToday: 0,
                        date: Date()
                    )
                )
                timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(300)))
            }
            completion(timeline)
        }
    }
}

// MARK: - Entry
struct DailySummaryEntry: TimelineEntry {
    let date: Date
    let data: DailySummaryModel
}

// MARK: - View
struct DailySummaryView: View {
    let entry: DailySummaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(.orange.opacity(0.15))
                    )
                
                Text("Today")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            // Metrics
            VStack(alignment: .leading, spacing: 8) {
                MetricRow(
                    icon: "figure.walk.circle.fill",
                    iconColor: .blue,
                    title: "Steps",
                    value: entry.data.formattedSteps
                )
                
                MetricRow(
                    icon: "location.circle.fill",
                    iconColor: .green,
                    title: "Distance",
                    value: entry.data.formattedDistance
                )
            }
            
            Spacer()
            
            // Motivational message
            Text(entry.data.motivationalMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Metric Row Component
private struct MetricRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    DailySummaryWidget()
} timeline: {
    DailySummaryEntry(
        date: Date(),
        data: DailySummaryModel(
            stepsToday: 8432,
            distanceToday: 6200,
            date: Date()
        )
    )
}
