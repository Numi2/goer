/*
Abstract:
Clean workout metrics view following Apple's Liquid Glass design principles.
*/

import SwiftUI
import HealthKit

struct MetricsView: View {
    @Environment(WorkoutManager.self) var workoutManager
    
    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(
                from: workoutManager.builder?.startDate ?? Date(),
                isPaused: workoutManager.session?.state == .paused
            )
        ) { context in
            LazyVGrid(columns: gridColumns, spacing: 16) {
                // Elapsed Time Card
                MetricCard(
                    icon: "clock.fill",
                    iconColor: .blue,
                    title: "Time",
                    value: ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime ?? 0),
                    subtitle: "Elapsed"
                )
                
                // Heart Rate Card
                MetricCard(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Heart Rate",
                    value: Text(workoutManager.metrics.getHeartRate()),
                    subtitle: "BPM"
                )
                
                // Active Energy Card
                MetricCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Active Energy",
                    value: Text(workoutManager.metrics.getActiveEnergy()),
                    subtitle: "Calories"
                )
                
                // Distance Card (if supported)
                if workoutManager.metrics.supportsDistance {
                    MetricCard(
                        icon: "location.fill",
                        iconColor: .green,
                        title: "Distance",
                        value: Text(workoutManager.metrics.getDistance()),
                        subtitle: "Covered"
                    )
                }
                
                // Speed Card (if supported)
                if workoutManager.metrics.supportsSpeed {
                    MetricCard(
                        icon: "speedometer",
                        iconColor: .purple,
                        title: "Speed",
                        value: Text(workoutManager.metrics.getSpeed()),
                        subtitle: "Current"
                    )
                }
            }
            .padding()
        }
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}

private struct MetricCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: Content
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
            
            // Content
            VStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                value
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .padding()
        .frame(minHeight: 120)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Timeline Schedule

private struct MetricsTimelineSchedule: TimelineSchedule {
    let startDate: Date
    let isPaused: Bool

    init(from startDate: Date, isPaused: Bool) {
        self.startDate = startDate
        self.isPaused = isPaused
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        let newMode = (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate, by: newMode).entries(from: startDate, mode: mode)

        return AnyIterator<Date> {
            return isPaused ? nil : baseSchedule.next()
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager()
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .running
    configuration.locationType = .outdoor
    workoutManager.selectedWorkout = configuration
    let metrics = MetricsModel(elapsedTime: 600,
                               heartRate: 72,
                               activeEnergy: 143,
                               distance: 5000,
                               speed: 1.4,
                               supportsDistance: true,
                               supportsSpeed: true)
    workoutManager.metrics = metrics
    
    return MetricsView()
        .environment(workoutManager)
        .padding()
        .background(.regularMaterial)
}
