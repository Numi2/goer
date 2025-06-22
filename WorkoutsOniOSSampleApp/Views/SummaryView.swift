/*
Abstract:
Revolutionary workout summary view with stunning liquid glass design and celebratory completion experience.
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
    
    @State private var animateContent = false
    @State private var celebrationEffect = false
    @State private var glowIntensity: Double = 0.0
    @State private var backgroundShift: Double = 0.0
    
    var body: some View {
        if workoutManager.workout == nil {
            // Loading state
            loadingView
        } else {
            // Summary content
            GlassEffectContainer(spacing: 25) {
                ZStack {
                    // Dynamic background
                    summaryBackground
                    
                    // Main content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 30) {
                            // Celebration header
                            celebrationHeader
                                .glassEffect(
                                    Glass()
                                        .tint(.green)
                                        .intensity(0.6)
                                        .interactive(true),
                                    in: RoundedRectangle(cornerRadius: 30, style: .continuous),
                                    isEnabled: true
                                )
                            
                            // Workout overview card
                            workoutOverviewCard
                            
                            // Metrics grid
                            metricsGrid
                            
                            // Achievement highlights
                            achievementHighlights
                                .glassEffect(
                                    Glass()
                                        .tint(.purple)
                                        .intensity(0.5)
                                        .interactive(true),
                                    in: RoundedRectangle(cornerRadius: 20, style: .continuous),
                                    isEnabled: true
                                )
                            
                            // Action buttons
                            actionButtons
                            
                            Spacer(minLength: 60)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                startSummaryAnimations()
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            // Animated progress indicator
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            colors: [.blue, .purple, .blue],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(celebrationEffect ? 360 : 0))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: celebrationEffect)
            }
            
            Text("Saving workout")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Analyzing your performance...")
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .glassEffect(
            Glass()
                .tint(.blue)
                .intensity(0.7)
                .interactive(true),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous),
            isEnabled: true
        )
        .advancedLiquidGlassCard(
            tint: .blue,
            variant: .clear,
            intensity: .medium
        )
        .padding(.horizontal, 40)
        .onAppear {
            celebrationEffect = true
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Background
    
    private var summaryBackground: some View {
        ZStack {
            // Primary gradient
            LinearGradient(
                colors: [.purple, .blue, .cyan],
                startPoint: backgroundShift < 0.5 ? .topLeading : .bottomLeading,
                endPoint: backgroundShift < 0.5 ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            
            // Celebration particles
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.yellow.opacity(0.6),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 5
                        )
                    )
                    .frame(width: CGFloat.random(in: 3...8))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...800) + (celebrationEffect ? -1000 : 0)
                    )
                    .opacity(celebrationEffect ? 0.0 : 1.0)
                    .animation(
                        .easeOut(duration: Double.random(in: 2...4))
                        .delay(Double(index) * 0.1),
                        value: celebrationEffect
                    )
            }
        }
    }
    
    // MARK: - Content Sections
    
    private var celebrationHeader: some View {
        VStack(spacing: 20) {
            // Celebration icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.green.opacity(0.4),
                                Color.green.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(celebrationEffect ? 1.2 : 1.0)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(celebrationEffect ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 10).delay(0.2), value: celebrationEffect)
            }
            
            // Success message
            VStack(spacing: 8) {
                Text("Workout Complete!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .green.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("Great job staying active!")
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .scaleEffect(animateContent ? 1.0 : 0.8)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15), value: animateContent)
    }
    
    private var workoutOverviewCard: some View {
        VStack(spacing: 16) {
            // Workout type and icon
            HStack(spacing: 16) {
                Image(systemName: workoutIconName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [workoutColor, workoutColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutDisplayName)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(workoutTypeDescription)
                        .font(.system(.callout, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .advancedLiquidGlassCard(
            tint: workoutColor,
            variant: .clear,
            intensity: .medium,
            enableMotionEffects: true
        )
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.1), value: animateContent)
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            // Duration metric
            SummaryMetricCard(
                icon: "clock.fill",
                iconColor: .blue,
                title: "Total Time",
                value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? "",
                isAnimated: animateContent,
                glowIntensity: glowIntensity
            )
            
            // Energy metric
            SummaryMetricCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "Total Energy",
                value: formatEnergy(),
                isAnimated: animateContent,
                glowIntensity: glowIntensity
            )
            
            // Distance metric (if available)
            if workoutManager.workout?.workoutConfiguration.supportsDistance ?? false {
                SummaryMetricCard(
                    icon: "location.fill",
                    iconColor: .green,
                    title: "Total Distance",
                    value: formatDistance(),
                    isAnimated: animateContent,
                    glowIntensity: glowIntensity
                )
            }
            
            // Average heart rate (placeholder)
            SummaryMetricCard(
                icon: "heart.fill",
                iconColor: .red,
                title: "Avg Heart Rate",
                value: "-- BPM",
                isAnimated: animateContent,
                glowIntensity: glowIntensity
            )
        }
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.2), value: animateContent)
    }
    
    private var achievementHighlights: some View {
        VStack(spacing: 16) {
            Text("Achievements")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Sample achievements
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
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.3), value: animateContent)
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
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundColor(.white)
            }
            .buttonStyle(GlassButtonStyle())
            
            // Done button
            Button {
                finishSummary()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("Done")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundColor(.white)
            }
            .buttonStyle(GlassButtonStyle())
        }
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.4), value: animateContent)
    }
    
    // MARK: - Computed Properties
    
    private var workoutIconName: String {
        guard let activityType = workoutManager.workoutConfiguration?.activityType else {
            return "figure.walk.circle.fill"
        }
        
        switch activityType {
        case .running: return "figure.run.circle.fill"
        case .walking: return "figure.walk.circle.fill"
        case .cycling: return "figure.outdoor.cycle.circle.fill"
        case .swimming: return "figure.pool.swim.circle.fill"
        case .yoga: return "figure.yoga.circle.fill"
        case .functionalStrengthTraining: return "figure.strengthtraining.functional.circle.fill"
        default: return "figure.walk.circle.fill"
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
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Share implementation would go here
    }
    
    private func finishSummary() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.8)) {
            workoutManager.resetWorkout()
        }
    }
    
    private func startSummaryAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateContent = true
        }
        
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            celebrationEffect = true
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: true)) {
            backgroundShift = 1.0
        }
        
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
    }
}

// MARK: - Supporting Views

/// Beautiful summary metric card
private struct SummaryMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let isAnimated: Bool
    let glowIntensity: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
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
                            endRadius: 30
                        )
                    )
                    .frame(width: 50, height: 50)
                    .scaleEffect(isAnimated ? 1.1 : 1.0)
                    .opacity(glowIntensity)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Content
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .frame(minHeight: 120)
        .advancedLiquidGlassCard(
            tint: iconColor,
            variant: .clear,
            intensity: .medium,
            enableMotionEffects: true
        )
    }
}

/// Achievement row display
private struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .advancedLiquidGlassCard(
            tint: color,
            variant: .clear,
            intensity: .light,
            enableMotionEffects: false
        )
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
    .preferredColorScheme(.dark)
}
