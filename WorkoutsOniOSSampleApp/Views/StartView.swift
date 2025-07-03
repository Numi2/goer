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
                    EnhancedWorkoutCard(
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
        .appleDynamicBackground(
            colors: [
                Color.accentColor.opacity(0.05),
                Color.blue.opacity(0.03),
                Color.green.opacity(0.02)
            ],
            intensity: 0.3
        )
        .safeAreaInset(edge: .bottom) {
            if let workout = selectedWorkout {
                EnhancedStartButton(workout: workout) {
                    workoutManager.selectedWorkout = workout
                    workoutManager.startWorkout()
                }
                .padding()
                .enhancedGlassCard(
                    variant: .prominent,
                    intensity: 1.2,
                    enableMorph: true,
                    tint: Color.accentColor
                )
                .padding()
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}

private struct EnhancedWorkoutCard: View {
    let configuration: HKWorkoutConfiguration
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Enhanced icon with liquid effects
                Image(systemName: configuration.symbol)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(workoutColor)
                    .frame(width: 72, height: 72)
                    .background {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        workoutColor.opacity(0.3),
                                        workoutColor.opacity(0.15),
                                        workoutColor.opacity(0.05)
                                    ],
                                    center: .topLeading,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [workoutColor.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                
                VStack(spacing: 6) {
                    Text(configuration.name)
                        .font(.system(size: 16, weight: .semibold))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(locationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(
                            Glass()
                                .tint(workoutColor)
                                .intensity(0.4)
                                .interactive(false),
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .enhancedGlassCard(
                variant: isSelected ? .prominent : .regular,
                intensity: isSelected ? 1.2 : 0.8,
                enableMorph: true,
                tint: isSelected ? workoutColor : .clear
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [workoutColor.opacity(0.6), workoutColor.opacity(0.2)] : [.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 0
                    )
            }
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
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

private struct EnhancedStartButton: View {
    let workout: HKWorkoutConfiguration
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text("Start \(workout.name)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: workout.symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color.accentColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(GlassButtonStyle(glass: Glass().interactive(true).intensity(1.2)))
    }
}

#Preview {
    NavigationStack {
        StartView()
            .environment(WorkoutManager())
    }
}
