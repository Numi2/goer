/*
Abstract:
Clean workout selection view following Apple's Liquid Glass design principles.
*/

import SwiftUI
import HealthKit

struct StartView: View {
    @Environment(WorkoutManager.self) var workoutManager
    @State private var selectedWorkout: HKWorkoutConfiguration?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(WorkoutTypes.workoutConfigurations, id: \.self) { configuration in
                    WorkoutCard(
                        configuration: configuration,
                        isSelected: selectedWorkout == configuration
                    ) {
                        selectedWorkout = configuration
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            if let workout = selectedWorkout {
                StartButton(workout: workout) {
                    workoutManager.selectedWorkout = workout
                    workoutManager.startWorkout()
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}

private struct WorkoutCard: View {
    let configuration: HKWorkoutConfiguration
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: configuration.symbol)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(workoutColor)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(workoutColor.opacity(0.15))
                    )
                
                VStack(spacing: 4) {
                    Text(configuration.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(locationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? workoutColor : Color.clear, lineWidth: 2)
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
    
    private var workoutColor: Color {
        switch configuration.activityType {
        case .running: return .orange
        case .walking: return .green
        case .cycling: return .blue
        case .swimming: return .cyan
        case .yoga: return .purple
        case .functionalStrengthTraining: return .red
        default: return .blue
        }
    }
    
    private var locationText: String {
        switch configuration.locationType {
        case .indoor: return "Indoor"
        case .outdoor: return "Outdoor"
        default: return "Flexible"
        }
    }
}

private struct StartButton: View {
    let workout: HKWorkoutConfiguration
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.headline)
                
                Text("Start \(workout.name)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: workout.symbol)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        StartView()
            .environment(WorkoutManager())
    }
}
