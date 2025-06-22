/*
Abstract:
SwiftUI workout controls view with stunning liquid glass design and immersive interaction feedback.
*/

import SwiftUI

struct ControlsView: View {
    @Environment(WorkoutManager.self) var workoutManager
    @State private var animateControls = false
    @State private var glowIntensity: Double = 0.0
    @State private var pauseButtonPulse = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Primary controls row
            HStack(spacing: 20) {
                // End workout button
                endWorkoutButton
                
                // Pause/Resume button
                pauseResumeButton
            }
            
            // Secondary actions (if needed)
            if workoutManager.state == .paused {
                secondaryActions
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .advancedLiquidGlassCard(
            tint: .gray,
            variant: .clear,
            intensity: .light,
            enableMotionEffects: true
        )
        .scaleEffect(animateControls ? 1.0 : 0.9)
        .opacity(animateControls ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.3), value: animateControls)
        .onAppear {
            startControlAnimations()
        }
    }
    
    // MARK: - Control Buttons
    
    private var endWorkoutButton: some View {
        ControlButton(
            icon: "xmark",
            iconSize: 24,
            title: "End",
            subtitle: "Workout",
            color: .red,
            glowIntensity: glowIntensity
        ) {
            endWorkoutWithConfirmation()
        }
    }
    
    private var pauseResumeButton: some View {
        ControlButton(
            icon: pauseResumeIcon,
            iconSize: 24,
            title: pauseResumeTitle,
            subtitle: pauseResumeSubtitle,
            color: pauseResumeColor,
          
            glowIntensity: glowIntensity
        ) {
            togglePauseResume()
        }
    }
    
    private var secondaryActions: some View {
        HStack(spacing: 16) {
            // Lock screen button
            SecondaryControlButton(
                icon: "lock.fill",
                title: "Lock",
                color: .blue,
                glowIntensity: glowIntensity
            ) {
                lockWorkoutScreen()
            }
            
            // Settings button
            SecondaryControlButton(
                icon: "gear",
                title: "Settings",
                color: .purple,
                glowIntensity: glowIntensity
            ) {
                openWorkoutSettings()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var pauseResumeIcon: String {
        switch workoutManager.state {
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        default: return "arrow.clockwise"
        }
    }
    
    private var pauseResumeTitle: String {
        switch workoutManager.state {
        case .running: return "Pause"
        case .paused: return "Resume"
        default: return "Start"
        }
    }
    
    private var pauseResumeSubtitle: String {
        switch workoutManager.state {
        case .running: return "Workout"
        case .paused: return "Workout"
        default: return "Again"
        }
    }
    
    private var pauseResumeColor: Color {
        switch workoutManager.state {
        case .running: return .yellow
        case .paused: return .green
        default: return .blue
        }
    }
    
    // MARK: - Actions
    
    private func endWorkoutWithConfirmation() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.6)) {
            workoutManager.endWorkout()
        }
    }
    
    private func togglePauseResume() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            workoutManager.togglePause()
        }
    }
    
    private func lockWorkoutScreen() {
        // Implementation for screen lock
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func openWorkoutSettings() {
        // Implementation for workout settings
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func startControlAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateControls = true
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
    }
}

/// A simple button style that scales the content while the user is pressing the button.
private struct PressScaleButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.95
    var animation: Animation = .easeOut(duration: 0.1)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}

/// Premium control button with advanced liquid glass styling
private struct ControlButton: View {
    let icon: String
    let iconSize: CGFloat
    let title: String
    let subtitle: String
    let color: Color
    let glowIntensity: Double
    let action: () -> Void
    
    init(
        icon: String,
        iconSize: CGFloat = 20,
        title: String,
        subtitle: String,
        color: Color,
        glowIntensity: Double,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconSize = iconSize
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.glowIntensity = glowIntensity
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with special effects
                ZStack {
                    // Glowing background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.4),
                                    color.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 35
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(1.0)
                    
                    // Main icon
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Text labels
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(.callout, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(PressScaleButtonStyle())
        .advancedLiquidGlassCard(
            tint: color,
            variant: .clear,
            intensity: .medium,
            enableMotionEffects: true
        )
        .scaleEffect(1.0)
    }
}

/// Compact secondary control button
private struct SecondaryControlButton: View {
    let icon: String
    let title: String
    let color: Color
    let glowIntensity: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PressScaleButtonStyle(scaleAmount: 0.95))
        .advancedLiquidGlassCard(
            tint: color,
            variant: .clear,
            intensity: .light,
            enableMotionEffects: false
        )
    }
}

#Preview {
    ControlsView()
        .environment(WorkoutManager())
        .preferredColorScheme(.dark)
        .padding()
}
