/*
Abstract:
Revolutionary countdown view with stunning liquid glass design, immersive animations, and magical visual effects.
*/

import SwiftUI
import HealthKit

struct CountDownView: View {
    @State private var manager = CountDownManager()
    @State private var pulseEffect = false
    @State private var glowIntensity: Double = 0.0
    @State private var particleOffset: CGFloat = 0
    @State private var backgroundPulse: Double = 1.0
    
    var body: some View {
        GlassEffectContainer(spacing: 35) {
            ZStack {
                // Dynamic background effects
                backgroundEffects
                
                // Main countdown content
                VStack(spacing: 60) {
                    // Header section
                    headerSection
                        .glassEffect(
                            Glass()
                                .tint(.orange)
                                .intensity(0.6)
                                .interactive(true),
                            in: RoundedRectangle(cornerRadius: 25, style: .continuous),
                            isEnabled: true
                        )
                    
                    // Countdown circle
                    countdownCircle
                    
                    // Ready indicator
                    readyIndicator
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 40)
                .padding(.top, 100)
            }
        }
        .onAppear {
            manager.startCountDown()
            startBackgroundAnimations()
        }
        .onReceive(manager.timerFinished) { _ in
            startWorkoutTransition()
        }
    }
    
    private var backgroundEffects: some View {
        ZStack {
            // Particle system
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.blue.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 10
                        )
                    )
                    .frame(width: 4, height: 4)
                    .position(
                        x: 200 + cos(Double(index) * .pi / 6 + particleOffset) * 150,
                        y: 400 + sin(Double(index) * .pi / 6 + particleOffset) * 150
                    )
                    .opacity(0.6)
            }
            
            // Ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.3),
                            Color.red.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(backgroundPulse)
                .opacity(glowIntensity)
        }
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Get Ready")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .orange.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
            
            Text("Prepare for your workout")
                .font(.system(.title3, design: .rounded, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var countdownCircle: some View {
        ZStack {
            // Background circle with liquid glass effect
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.orange.opacity(0.2),
                            Color.red.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .glassEffect(
                    Glass()
                        .tint(.orange)
                        .intensity(0.5)
                        .interactive(true),
                    in: Circle(),
                    isEnabled: true
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: manager.trimValue)
                .stroke(
                    AngularGradient(
                        colors: [
                            .orange,
                            .red,
                            .pink,
                            .orange
                        ],
                        center: .center,
                        angle: .degrees(-90)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(
                    manager.isSettingTrim ? nil : .linear(duration: 1),
                    value: manager.timeRemaining
                )
                .shadow(color: .orange.opacity(0.8), radius: 8, x: 0, y: 0)
                .overlay {
                    // Inner liquid glass overlay
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 200)
                        .overlay {
                            countdownText
                        }
                }
            
            // Outer glow ring
            Circle()
                .stroke(
                    Color.orange.opacity(glowIntensity * 0.8),
                    lineWidth: 3
                )
                .frame(width: 300, height: 300)
                .blur(radius: 4)
                .scaleEffect(pulseEffect ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseEffect)
        }
    }
    
    private var countdownText: some View {
        VStack(spacing: 8) {
            // Main countdown number
            Text("\(Int(manager.timeRemaining))")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            .orange.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .contentTransition(.numericText(countsDown: true))
                .animation(.bouncy(duration: 0.6), value: manager.timeRemaining)
                .shadow(color: .orange.opacity(0.7), radius: 15, x: 0, y: 0)
            
            // Seconds label
            Text("seconds")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(2)
        }
    }
    
    private var readyIndicator: some View {
        VStack(spacing: 20) {
            // Pulsing ready indicator
            if manager.timeRemaining <= 1 {
                Text("START!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.green)
                    .scaleEffect(pulseEffect ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: pulseEffect)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Workout type indicator
            if let workoutType = WorkoutManager.shared.selectedWorkout?.activityType {
                HStack(spacing: 12) {
                    Image(systemName: workoutIconName(for: workoutType))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(workoutDisplayName(for: workoutType))
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .advancedLiquidGlassCard(
                    tint: .blue,
                    variant: .clear,
                    intensity: .light
                )
            }
        }
    }
    
    private func startBackgroundAnimations() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            particleOffset = .pi * 2
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            backgroundPulse = 1.2
            glowIntensity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.5)) {
            pulseEffect = true
        }
    }
    
    private func startWorkoutTransition() {
        withAnimation(.easeInOut(duration: 0.8)) {
            glowIntensity = 2.0
            backgroundPulse = 2.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
}

#Preview {
    CountDownView()
        .preferredColorScheme(.dark)
}

