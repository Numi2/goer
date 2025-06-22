/*
Abstract:
Clean workout summary view following Apple's Liquid Glass design principles.
*/

import SwiftUI
import HealthKit

struct SummaryView: View {
    @Environment(WorkoutManager.self) var workoutManager
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        if workoutManager.workout == nil {
            loadingView
        } else {
            summaryContent
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Saving workout")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Analyzing your performance...")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
    
    private var summaryContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Celebration header
                celebrationHeader
                
                // Workout overview
                workoutOverviewCard
                
                // Metrics grid
                metricsGrid
                
                // Achievements
                achievementSection
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private var celebrationHeader: some View {
        VStack(spacing: 20) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.green)
            
            // Success message
            VStack(spacing: 8) {
                Text("Workout Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Great job staying active!")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var workoutOverviewCard: some View {
        HStack(spacing: 16) {
            Image(systemName: workoutIconName)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(workoutColor)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(workoutColor.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutDisplayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(workoutTypeDescription)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            // Duration metric
            SummaryMetricCard(
                icon: "clock.fill",
                iconColor: .blue,
                title: "Total Time",
                value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? ""
            )
            
            // Energy metric
            SummaryMetricCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "Total Energy",
                value: formatEnergy()
            )
            
            // Distance metric (if available)
            if workoutManager.workout?.workoutConfiguration.supportsDistance ?? false {
                SummaryMetricCard(
                    icon: "location.fill",
                    iconColor: .green,
                    title: "Total Distance",
                    value: formatDistance()
                )
            }
            
            // Average heart rate (placeholder)
            SummaryMetricCard(
                icon: "heart.fill",
                iconColor: .red,
                title: "Avg Heart Rate",
                value: "-- BPM"
            )
        }
    }
    
    private var achievementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                AchievementRow(
                    icon: "trophy.fill",
                    title: "Workout Completed",
                    description: "You finished your workout session",
                    color: .yellow
                )
                
                AchievementRow(
                    icon: "target",
                    title: "Goal Achieved",
                    description: "You met your activity goals",
                    color: .green
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Share workout button
            Button {
                shareWorkout()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Share Workout")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            // Done button
            Button {
                finishSummary()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("Done")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Computed Properties
    
    private var workoutIconName: String {
        guard let activityType = workoutManager.workoutConfiguration?.activityType else {
            return "figure.walk"
        }
        
        switch activityType {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.yoga"
        case .functionalStrengthTraining: return "figure.strengthtraining.functional"
        default: return "figure.walk"
        }
    }
    
    private var workoutColor: Color {
        guard let activityType = workoutManager.workoutConfiguration?.activityType else {
            return .green
        }
        
        switch activityType {
        case .running: return .orange
        case .walking: return .green
        case .cycling: return .blue
        case .swimming: return .cyan
        case .yoga: return .purple
        case .functionalStrengthTraining: return .red
        default: return .green
        }
    }
    
    private var workoutDisplayName: String {
        workoutManager.workoutConfiguration?.name ?? "Workout"
    }
    
    private var workoutTypeDescription: String {
        guard let locationType = workoutManager.workoutConfiguration?.locationType else {
            return "Flexible Location"
        }
        
        switch locationType {
        case .indoor: return "Indoor Workout"
        case .outdoor: return "Outdoor Workout"
        default: return "Flexible Location"
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatEnergy() -> String {
        let energyValue = workoutManager.workout?.statistics(for: .quantityType(forIdentifier: .activeEnergyBurned)!)?
            .sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        
        return Measurement(value: energyValue, unit: UnitEnergy.kilocalories)
            .formatted(.measurement(width: .abbreviated, usage: .workout))
    }
    
    private func formatDistance() -> String {
        let distanceValue = workoutManager.workout?.totalDistance?
            .doubleValue(for: .meter()) ?? 0
        
        return Measurement(value: distanceValue, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }
    
    private func shareWorkout() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        // Share implementation would go here
    }
    
    private func finishSummary() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        workoutManager.resetWorkout()
    }
}

// MARK: - Supporting Views

private struct SummaryMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
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
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(minHeight: 100)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let workoutManager = WorkoutManager()
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .running
    configuration.locationType = .outdoor
    workoutManager.selectedWorkout = configuration
    
    return NavigationStack {
        SummaryView()
    }
    .environment(workoutManager)
}
