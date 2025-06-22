/*
Abstract:
Clean SwiftUI workout controls view following Apple's design principles.
*/

import SwiftUI

struct ControlsView: View {
    @Environment(WorkoutManager.self) var workoutManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Primary controls
            HStack(spacing: 16) {
                endWorkoutButton
                pauseResumeButton
            }
            
            // Secondary controls when paused
            if workoutManager.state == .paused {
                HStack(spacing: 16) {
                    lockButton
                    settingsButton
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
    }
    
    private var endWorkoutButton: some View {
        Button {
            workoutManager.endWorkout()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("End")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.red.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var pauseResumeButton: some View {
        Button {
            workoutManager.togglePause()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: pauseResumeIcon)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(pauseResumeTitle)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(pauseResumeColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(pauseResumeColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(pauseResumeColor.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var lockButton: some View {
        Button {
            // Lock screen implementation
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.subheadline)
                
                Text("Lock")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    private var settingsButton: some View {
        Button {
            // Settings implementation
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "gear")
                    .font(.subheadline)
                
                Text("Settings")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.purple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var pauseResumeIcon: String {
        switch workoutManager.state {
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        default: return "play.fill"
        }
    }
    
    private var pauseResumeTitle: String {
        switch workoutManager.state {
        case .running: return "Pause"
        case .paused: return "Resume"
        default: return "Start"
        }
    }
    
    private var pauseResumeColor: Color {
        switch workoutManager.state {
        case .running: return .orange
        case .paused: return .green
        default: return .blue
        }
    }
}

#Preview {
    ControlsView()
        .environment(WorkoutManager())
        .padding()
        .background(.regularMaterial)
}
