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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // Big streak number
            Text("\(entry.streak)")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundStyle(entry.streak > 0 ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(entry.streak == 1 ? "Day" : "Days")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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

