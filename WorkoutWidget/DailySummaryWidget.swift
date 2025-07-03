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
                
                // WidgetKit treats 15 min as the practical lower-bound for non-Live-Activity widgets.
                // Updating more aggressively would be throttled and waste budget without user benefit.
                // A 15-minute cadence gives users near-real-time feedback while respecting battery life.
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
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced Header
            LiquidWidgetHeader(
                icon: "figure.walk",
                iconColor: Color.accentColor,
                title: "Today",
                subtitle: "Daily Summary",
                variant: .expanded
            )
            
            // Metrics with enhanced glass effects
            VStack(alignment: .leading, spacing: 12) {
                LiquidMetricDisplay(
                    icon: "figure.walk.circle.fill",
                    iconColor: .blue,
                    title: "Steps",
                    value: entry.data.formattedSteps,
                    layout: .horizontal,
                    style: .prominent
                )
                
                LiquidMetricDisplay(
                    icon: "location.circle.fill",
                    iconColor: .green,
                    title: "Distance",
                    value: entry.data.formattedDistance,
                    layout: .horizontal,
                    style: .prominent
                )
            }
            
            Spacer()
            
            // Enhanced motivational message with liquid background
            Text(entry.data.motivationalMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .quickGlass(
                    tint: Color.accentColor,
                    intensity: 0.6,
                    interactive: false
                )
                .accessibilityLabel(entry.data.motivationalMessage)
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
                Color.accentColor.opacity(0.15),
                Color.blue.opacity(0.1),
                Color.green.opacity(0.05)
            ],
            intensity: 0.8
        )
    }
}

// MARK: - Metric Row Component
// Deprecated: Replaced by shared `MetricDisplay` (see `Shared/WidgetComponents.swift`).
// Existing private struct removed to avoid duplication.

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

#Preview("Dark", as: .systemSmall) {
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
