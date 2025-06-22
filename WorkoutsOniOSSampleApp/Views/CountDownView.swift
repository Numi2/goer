/*
Abstract:
Clean countdown view following Apple's Liquid Glass design principles.
*/

import SwiftUI
import HealthKit

struct CountDownView: View {
    @State private var manager = CountDownManager()
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header section
            VStack(spacing: 16) {
                Text("Get Ready")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Prepare for your workout")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            // Countdown circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(.tertiary, lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: manager.trimValue)
                    .stroke(.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(manager.isSettingTrim ? nil : .linear(duration: 1), value: manager.timeRemaining)
                
                // Countdown text
                VStack(spacing: 8) {
                    Text("\(Int(manager.timeRemaining))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.bouncy(duration: 0.6), value: manager.timeRemaining)
                    
                    Text("seconds")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            // Ready indicator
            VStack(spacing: 16) {
                if manager.timeRemaining <= 1 {
                    Text("START!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Workout type indicator
                if let workoutType = WorkoutManager.shared.selectedWorkout?.activityType {
                    HStack(spacing: 12) {
                        Image(systemName: workoutIconName(for: workoutType))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(workoutColor(for: workoutType))
                        
                        Text(workoutDisplayName(for: workoutType))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            manager.startCountDown()
        }
        .onReceive(manager.timerFinished) { _ in
            WorkoutManager.shared.startWorkout()
        }
    }
    
    private func workoutIconName(for activityType: HKWorkoutActivityType) -> String {
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
    
    private func workoutDisplayName(for activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .yoga: return "Yoga"
        case .functionalStrengthTraining: return "Strength Training"
        default: return "Workout"
        }
    }
    
    private func workoutColor(for activityType: HKWorkoutActivityType) -> Color {
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
}

#Preview {
    CountDownView()
}

