/*
Abstract:
Simple Distance Widget showing today's distance.
Following Apple's Liquid Glass design principles.
*/

import SwiftUI
import WidgetKit

struct DistanceWidget: Widget {
    let kind: String = "DistanceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DistanceProvider()) { entry in
            DistanceView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Distance")
        .description("Track your daily walking distance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Provider
struct DistanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> DistanceEntry {
        DistanceEntry(
            date: Date(),
            distance: 4200
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DistanceEntry) -> ()) {
        let entry = DistanceEntry(
            date: Date(),
            distance: 4200
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<DistanceEntry>) -> ()) {
        Task { @MainActor in
            let timeline: Timeline<DistanceEntry>
            do {
                let data = try await HealthKitProvider.shared.fetchDailySummary()
                let entry = DistanceEntry(date: Date(), distance: data.distanceToday)
                
                // Update every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            } catch {
                // Fallback entry on error
                let fallbackEntry = DistanceEntry(
                    date: Date(),
                    distance: 0
                )
                timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(300)))
            }
            completion(timeline)
        }
    }
}

// MARK: - Entry
struct DistanceEntry: TimelineEntry {
    let date: Date
    let distance: Double // in meters
    
    var formattedDistance: String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
}

// MARK: - View with Liquid Glass Design
struct DistanceView: View {
    let entry: DistanceEntry
    
    var body: some View {
        ZStack {
            // Liquid glass background
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Icon and title
                VStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.green)
                    
                    Text("Distance")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                // Distance value
                Text(entry.formattedDistance)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    DistanceWidget()
} timeline: {
    DistanceEntry(
        date: Date(),
        distance: 6200
    )
}

#Preview("Dark", as: .systemSmall) {
    DistanceWidget()
} timeline: {
    DistanceEntry(
        date: Date(),
        distance: 6200
    )
}