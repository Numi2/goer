/*
Abstract:
Clean SwiftUI workout session view following Apple's design principles.
*/

import SwiftUI
import HealthKit

struct SessionView: View {
    @Environment(WorkoutManager.self) var workoutManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Workout Header
                workoutHeader
                
                // Metrics
                MetricsView()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                
                // Controls
                ControlsView()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationBarHidden(true)
        .background(.regularMaterial)
    }
    
    private var workoutHeader: some View {
        VStack(spacing: 12) {
            // Workout Icon
            Image(systemName: workoutIconName)
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(workoutColor)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(workoutColor.opacity(0.15))
                )
            
            // Workout Info
            VStack(spacing: 8) {
                Text(workoutDisplayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 12) {
                    // Status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(statusText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    // Location type
                    Text(workoutTypeText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.2), in: Capsule())
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Computed Properties
    
    private var workoutColor: Color {
        guard let activityType = workoutManager.workoutConfiguration?.activityType else {
            return .blue
        }
        
        switch activityType {
        case .running: return .orange
        case .walking: return .green
        case .cycling: return .blue
        case .swimming: return .cyan
        case .yoga: return .purple
        case .functionalStrengthTraining: return .red
        default: return .blue
        }
    }
    
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
    
    private var workoutDisplayName: String {
        workoutManager.workoutConfiguration?.name ?? "Workout"
    }
    
    private var workoutTypeText: String {
        guard let locationType = workoutManager.workoutConfiguration?.locationType else {
            return "Flexible"
        }
        
        switch locationType {
        case .indoor: return "Indoor"
        case .outdoor: return "Outdoor"
        default: return "Flexible"
        }
    }
    
    private var statusText: String {
        switch workoutManager.state {
        case .notStarted: return "Not Started"
        case .running: return "Active"
        case .paused: return "Paused"
        case .prepared: return "Ready"
        case .stopped: return "Stopped"
        case .ended: return "Completed"
        @unknown default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch workoutManager.state {
        case .notStarted: return .secondary
        case .running: return .green
        case .paused: return .orange
        case .prepared: return .blue
        case .stopped: return .secondary
        case .ended: return .blue
        @unknown default: return .secondary
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager()
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .running
    configuration.locationType = .outdoor
    workoutManager.selectedWorkout = configuration
    
    return SessionView()
        .environment(workoutManager)
}

