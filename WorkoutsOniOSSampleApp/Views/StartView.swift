/*
Abstract:
Revolutionary workout selection view with stunning liquid glass design and immersive user experience.
*/

import SwiftUI
import HealthKit

struct StartView: View {
    @Environment(WorkoutManager.self) var workoutManager
    @State private var selectedWorkout: HKWorkoutConfiguration?
    @State private var animateCards = false
    @State private var pulseSelection = false
    
    var body: some View {
        GlassEffectContainer(spacing: 30) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero section
                    heroSection
                        .glassEffect(
                            Glass()
                                .tint(.blue)
                                .intensity(0.8)
                                .interactive(true),
                            in: RoundedRectangle(cornerRadius: 30, style: .continuous),
                            isEnabled: true
                        )
                    
                    // Workout cards grid
                    workoutCardsSection
                        .padding(.top, 40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            workoutManager.requestAuthorization()
            startCardAnimations()
        }
        .overlay(alignment: .bottom) {
            if selectedWorkout != nil {
                startWorkoutButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
            }
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            // App title with liquid glass effect
            Text("Goer")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8), .blue.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Choose your workout")
                .font(.system(.title2, design: .rounded, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var workoutCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(Array(WorkoutTypes.workoutConfigurations.enumerated()), id: \.element) { index, configuration in
                WorkoutCard(
                    configuration: configuration,
                    isSelected: selectedWorkout == configuration,
                    animationDelay: Double(index) * 0.1
                ) {
                    selectWorkout(configuration)
                }
                .scaleEffect(animateCards ? 1.0 : 0.8)
                .opacity(animateCards ? 1.0 : 0.0)
                .animation(
                    .interpolatingSpring(stiffness: 200, damping: 15)
                    .delay(Double(index) * 0.1),
                    value: animateCards
                )
            }
        }
    }
    
    private var startWorkoutButton: some View {
        Button {
            if let workout = selectedWorkout {
                workoutManager.selectedWorkout = workout
                withAnimation(.easeInOut(duration: 0.8)) {
                    workoutManager.startWorkout()
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Start Workout")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                
                if pulseSelection {
                    Image(systemName: selectedWorkout?.symbol ?? "figure.walk")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .foregroundColor(.white)
        }
        .buttonStyle(GlassButtonStyle())
        .scaleEffect(pulseSelection ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseSelection)
        .onAppear {
            pulseSelection = true
        }
    }
    
    private func selectWorkout(_ configuration: HKWorkoutConfiguration) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            selectedWorkout = configuration
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func startCardAnimations() {
        withAnimation {
            animateCards = true
        }
    }
}

/// Beautiful workout selection card with advanced liquid glass styling
private struct WorkoutCard: View {
    let configuration: HKWorkoutConfiguration
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    @State private var isHovered = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Icon with dynamic effects
                ZStack {
                    // Glowing background for icon
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    workoutColor.opacity(0.3),
                                    workoutColor.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                    
                    // Workout icon
                    Image(systemName: configuration.symbol)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [workoutColor, workoutColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                // Workout name
                Text(configuration.name)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Activity type indicator
                Text(activityTypeDescription)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(workoutColor.opacity(0.2))
                    )
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .glassEffect(
            Glass()
                .tint(workoutColor)
                .intensity(isSelected ? 1.0 : 0.6)
                .interactive(true),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous),
            isEnabled: true
        )
        .advancedLiquidGlassCard(
            tint: workoutColor,
            variant: isSelected ? .regular : .clear,
            intensity: isSelected ? .heavy : .medium,
            enableMotionEffects: true
        )
        .scaleEffect(isSelected ? 1.05 : (isHovered ? 1.02 : 1.0))
        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            startIconRotation()
        }
        .overlay {
            if isSelected {
                // Selection indicator
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 32, height: 32)
                            )
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
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
    
    private var activityTypeDescription: String {
        switch configuration.locationType {
        case .indoor: return "Indoor"
        case .outdoor: return "Outdoor"
        default: return "Flexible"
        }
    }
    
    private func startIconRotation() {
        withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

#Preview {
    NavigationStack {
        StartView()
            .environment(WorkoutManager())
    }
    .preferredColorScheme(.dark)
}
