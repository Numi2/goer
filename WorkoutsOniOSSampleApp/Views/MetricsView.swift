/*
Abstract:
Revolutionary workout metrics view with stunning liquid glass design and immersive data visualization.
*/

import SwiftUI
import HealthKit

struct MetricsView: View {
    @Environment(WorkoutManager.self) var workoutManager
    @State private var animateMetrics = false
    @State private var pulseHeartRate = false
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        GlassEffectContainer(spacing: 15) {
            TimelineView(
                MetricsTimelineSchedule(
                    from: workoutManager.builder?.startDate ?? Date(),
                    isPaused: workoutManager.session?.state == .paused
                )
            ) { context in
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    // Elapsed Time Card
                    elapsedTimeCard
                    
                    // Heart Rate Card
                    heartRateCard
                    
                    // Active Energy Card
                    activeEnergyCard
                    
                    // Distance Card (if supported)
                    if workoutManager.metrics.supportsDistance {
                        distanceCard
                    }
                    
                    // Speed Card (if supported)
                    if workoutManager.metrics.supportsSpeed {
                        speedCard
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .onAppear {
            startMetricAnimations()
        }
    }
    
    // MARK: - Metric Cards
    
    private var elapsedTimeCard: some View {
        MetricCard(
            icon: "clock.fill",
            iconColor: .blue,
            title: "Time",
            value: ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime ?? 0),
            subtitle: "Elapsed",
            isAnimated: animateMetrics,
            glowIntensity: glowIntensity
        )
    }
    
    private var heartRateCard: some View {
        MetricCard(
            icon: "heart.fill",
            iconColor: .red,
            title: "Heart Rate",
            value: Text(workoutManager.metrics.getHeartRate()),
            subtitle: "BPM",
            isAnimated: pulseHeartRate,
            glowIntensity: glowIntensity,
            specialEffect: .pulse
        )
    }
    
    private var activeEnergyCard: some View {
        MetricCard(
            icon: "flame.fill",
            iconColor: .orange,
            title: "Active Energy",
            value: Text(workoutManager.metrics.getActiveEnergy()),
            subtitle: "Calories",
            isAnimated: animateMetrics,
            glowIntensity: glowIntensity,
            specialEffect: .flame
        )
    }
    
    private var distanceCard: some View {
        MetricCard(
            icon: "location.fill",
            iconColor: .green,
            title: "Distance",
            value: Text(workoutManager.metrics.getDistance()),
            subtitle: "Covered",
            isAnimated: animateMetrics,
            glowIntensity: glowIntensity
        )
    }
    
    private var speedCard: some View {
        MetricCard(
            icon: "speedometer",
            iconColor: .purple,
            title: "Speed",
            value: Text(workoutManager.metrics.getSpeed()),
            subtitle: "Current",
            isAnimated: animateMetrics,
            glowIntensity: glowIntensity,
            specialEffect: .speed
        )
    }
    
    // MARK: - Grid Configuration
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ]
    }
    
    // MARK: - Animation Functions
    
    private func startMetricAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateMetrics = true
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseHeartRate = true
        }
        
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
    }
}

/// Beautiful metric card with advanced liquid glass styling and animations
private struct MetricCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: Content
    let subtitle: String
    let isAnimated: Bool
    let glowIntensity: Double
    let specialEffect: SpecialEffect?
    
    @State private var effectAnimation = false
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        value: Content,
        subtitle: String,
        isAnimated: Bool,
        glowIntensity: Double,
        specialEffect: SpecialEffect? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.isAnimated = isAnimated
        self.glowIntensity = glowIntensity
        self.specialEffect = specialEffect
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon section with special effects
            ZStack {
                // Glowing background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.4),
                                iconColor.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimated ? 1.1 : 1.0)
                    .opacity(glowIntensity)
                
                // Special effect layer
                if let effect = specialEffect {
                    specialEffectView(for: effect)
                }
                
                // Main icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isAnimated ? 1.05 : 1.0)
            }
            
            // Content section
            VStack(spacing: 8) {
                // Title
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(1)
                
                // Value
                value
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text(subtitle)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(minHeight: 160)
        .glassEffect(
            Glass()
                .tint(iconColor)
                .intensity(0.7)
                .interactive(true),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous),
            isEnabled: true
        )
        .advancedLiquidGlassCard(
            tint: iconColor,
            variant: .clear,
            intensity: .medium,
            enableMotionEffects: true
        )
        .scaleEffect(isAnimated ? 1.0 : 0.9)
        .opacity(isAnimated ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.2), value: isAnimated)
        .onAppear {
            if specialEffect != nil {
                startSpecialEffectAnimation()
            }
        }
    }
    
    @ViewBuilder
    private func specialEffectView(for effect: SpecialEffect) -> some View {
        switch effect {
        case .pulse:
            Circle()
                .stroke(iconColor.opacity(0.6), lineWidth: 2)
                .frame(width: 70, height: 70)
                .scaleEffect(effectAnimation ? 1.3 : 1.0)
                .opacity(effectAnimation ? 0.0 : 0.8)
                .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: effectAnimation)
            
        case .flame:
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(iconColor.opacity(0.7))
                    .frame(width: 2, height: CGFloat.random(in: 8...16))
                    .position(
                        x: 30 + CGFloat(index - 1) * 8,
                        y: effectAnimation ? 25 : 35
                    )
                    .opacity(effectAnimation ? 0.3 : 0.8)
            }
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: effectAnimation)
            
        case .speed:
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(iconColor.opacity(0.6))
                        .frame(width: 2, height: CGFloat(4 + index * 3))
                        .scaleEffect(x: 1, y: effectAnimation ? 1.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: effectAnimation
                        )
                }
            }
        }
    }
    
    private func startSpecialEffectAnimation() {
        withAnimation {
            effectAnimation = true
        }
    }
}

/// Special effects for metric cards
private enum SpecialEffect {
    case pulse, flame, speed
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

// MARK: - Preview

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
        .preferredColorScheme(.dark)
        .padding()
}
