/*
Abstract:
A WidgetKit widget that shows the user's **current streak** of completed health
goals.  It pulls daily totals from HealthKit (via the cache that is maintained
by the main app), evaluates whether the daily goal was met and counts
consecutive successes starting with *today*.

The widget can be customised through the `SelectMetricIntent`, allowing the
user to pick the metric (currently only *steps*) and change the threshold (e.g.
10 000 steps).
*/

import SwiftUI
import WidgetKit
import AppIntents

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: SelectMetricIntent.self,
                               provider: StreakProvider()) { entry in
            StreakView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Current Streak")
        .description("See how many days in a row you have reached your health goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Provider

struct StreakProvider: AppIntentTimelineProvider {
    typealias Intent = SelectMetricIntent

    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), metric: .steps, threshold: 10_000, streak: 3)
    }

    func snapshot(for configuration: SelectMetricIntent, in context: Context) async -> StreakEntry {
        // Safely convert the intent values to non-optional model values
        let metric = configuration.metric
            .flatMap { Metric($0.rawValue) } ?? .steps
        let threshold = configuration.threshold ?? 10_000

        return StreakEntry(date: Date(),
                           metric: metric,
                           threshold: threshold,
                           streak: 7)
    }

    func timeline(for configuration: SelectMetricIntent, in context: Context) async -> Timeline<StreakEntry> {
        // 1. Determine the selected metric & threshold (fall back to sensible defaults)
        let metric = configuration.metric
            .flatMap { Metric($0.rawValue) } ?? .steps
        let threshold = configuration.threshold ?? 10_000

        // 2. Pull cached totals on the main actor because `StreakCache` is `@MainActor`
        let totals = await MainActor.run { StreakCache.shared.totals(for: metric, back: 30) }

        // 3. Evaluate the streak on a background actor to avoid blocking the timeline provider
        let streak = await StreakEngine.shared.evaluate(totals: totals, threshold: threshold)

        // 4. Create entry
        let entry = StreakEntry(date: Date(), metric: metric, threshold: threshold, streak: streak)

        // 5. Schedule the next update shortly after midnight.
        // Streak only changes once per day at rollover, so we align refresh ~5 minutes after midnight
        // to ensure HealthKit has written the previous day's data.
        var nextUpdate: Date
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            nextUpdate = Calendar.current.startOfDay(for: tomorrow)
            nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: nextUpdate) ?? nextUpdate
        } else {
            nextUpdate = Date().addingTimeInterval(60 * 60 * 24)
        }

        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let metric: Metric
    let threshold: Double
    let streak: Int
}

// MARK: - View

struct StreakView: View {
    let entry: StreakEntry

    private var title: String {
        "\(entry.metric.displayName) Goal"
    }

    private var subtitle: String {
        "\(Int(entry.threshold)) \(entry.metric.displayName.lowercased())"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced Header with flame effect
            LiquidWidgetHeader(
                icon: "flame.fill",
                iconColor: .red,
                title: title,
                subtitle: subtitle,
                variant: .expanded
            )

            // Enhanced streak display with liquid morphing
            VStack(alignment: .leading, spacing: 8) {
                Text("\(entry.streak)")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(streakGradient)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .quickGlass(
                        tint: streakColor,
                        intensity: 0.8,
                        interactive: false
                    )

                Text(entry.streak == 1 ? "Day" : "Days")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .quickGlass(
                        tint: streakColor,
                        intensity: 0.4,
                        interactive: false
                    )
            }
            
            Spacer()
            
            // Streak status indicator
            HStack {
                Image(systemName: streakStatusIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(streakColor)
                
                Text(streakStatusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .quickGlass(
                tint: streakColor,
                intensity: 0.3,
                interactive: false
            )
        }
        .padding()
        .enhancedGlassCard(
            variant: entry.streak > 0 ? .prominent : .regular,
            intensity: 1.0,
            enableMorph: true,
            tint: streakColor
        )
        .dynamicLiquidBackground(
            colors: streakBackgroundColors,
            intensity: entry.streak > 0 ? 0.9 : 0.4
        )
    }
    
    private var streakColor: Color {
        switch entry.streak {
        case 0: return .gray
        case 1...3: return .orange
        case 4...7: return .yellow
        case 8...14: return .green
        case 15...30: return .blue
        default: return .purple
        }
    }
    
    private var streakGradient: LinearGradient {
        LinearGradient(
            colors: [
                streakColor,
                streakColor.opacity(0.8),
                streakColor.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var streakBackgroundColors: [Color] {
        [
            streakColor.opacity(0.2),
            Color.red.opacity(0.1),
            streakColor.opacity(0.05)
        ]
    }
    
    private var streakStatusIcon: String {
        switch entry.streak {
        case 0: return "moon.zzz"
        case 1...3: return "flame"
        case 4...7: return "flame.fill"
        case 8...14: return "bolt.fill"
        case 15...30: return "star.fill"
        default: return "crown.fill"
        }
    }
    
    private var streakStatusText: String {
        switch entry.streak {
        case 0: return "Start your streak today!"
        case 1: return "Great start! Keep it up!"
        case 2...3: return "Building momentum..."
        case 4...7: return "You're on fire!"
        case 8...14: return "Incredible consistency!"
        case 15...30: return "Streak master!"
        default: return "Legendary dedication!"
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .init(), metric: .steps, threshold: 10_000, streak: 5)
}

#Preview("Dark", as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .init(), metric: .steps, threshold: 10_000, streak: 5)
}

