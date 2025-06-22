/*
Abstract:
SWiftUI n HealthKit workout session view with stunning liquid glass design and immersive real-time metrics display.
*/

import SwiftUI
import HealthKit

struct SessionView: View {
    @Environment(WorkoutManager.self) var workoutManager
    @State private var pulseMetrics = false
    @State private var backgroundShift: Double = 0.0
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Dynamic background with workout-specific colors
            dynamicBackground
            
            // Main content with glass effect container
            GlassEffectContainer(spacing: 25) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        // Header section with workout icon
                        headerSection
                        
                        // Main metrics display
                        MetricsView()
                            .glassEffect(
                                Glass()
                                    .tint(workoutIconColor)
                                    .intensity(0.8)
                                    .interactive(true),
                                in: RoundedRectangle(cornerRadius: 24, style: .continuous),
                                isEnabled: true
                            )
                            .scaleEffect(pulseMetrics ? 1.02 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseMetrics)
                        
                        // Controls section
                        ControlsView()
                            .glassEffect(
                                Glass()
                                    .tint(workoutIconColor)
                                    .intensity(0.6)
                                    .interactive(true),
                                in: RoundedRectangle(cornerRadius: 20, style: .continuous),
                                isEnabled: true
                            )
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                }
            }
        }
        .onAppear {
            startSessionAnimations()
        }
    }
    
    private var dynamicBackground: some View {
        ZStack {
            // Primary gradient layer
            LinearGradient(
                colors: workoutColors,
                startPoint: backgroundShift < 0.5 ? .topLeading : .bottomLeading,
                endPoint: backgroundShift < 0.5 ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            
            // Animated secondary layer
            RadialGradient(
                colors: [
                    workoutColors.first?.opacity(0.4) ?? Color.clear,
                    Color.clear,
                    workoutColors.last?.opacity(0.3) ?? Color.clear
                ],
                center: UnitPoint(x: backgroundShift, y: 1 - backgroundShift),
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            // Ambient glow layer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            workoutColors.first?.opacity(glowIntensity * 0.3) ?? Color.clear,
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .position(x: 200, y: 300)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Workout icon with dynamic effects
            ZStack {
                // Glowing background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                workoutIconColor.opacity(0.4),
                                workoutIconColor.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseMetrics ? 1.1 : 1.0)
                
                // Main icon
                Image(systemName: workoutIconName)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                workoutIconColor,
                                workoutIconColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: workoutIconColor.opacity(0.8), radius: 10, x: 0, y: 0)
            }
            
            // Workout status
            workoutStatusCard
        }
    }
    
    private var workoutStatusCard: some View {
        VStack(spacing: 12) {
            Text(workoutDisplayName)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                // Status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                        .scaleEffect(pulseMetrics ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseMetrics)
                    
                    Text(statusText)
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Workout type indicator
                Text(workoutTypeText)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(workoutIconColor.opacity(0.3))
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .advancedLiquidGlassCard(
            tint: workoutIconColor,
            variant: .clear,
            intensity: .medium,
            enableMotionEffects: true
        )
    }
    
    // MARK: - Computed Properties
    
    private var workoutColors: [Color] {
        guard let activityType = workoutManager.workoutConfiguration?.activityType else {
            return [.green, .mint, .cyan]
        }
        
        switch activityType {
        case .running:
            return [.orange, .red, .pink]
        case .walking:
            return [.green, .mint, .teal]
        case .cycling:
            return [.blue, .cyan, .indigo]
        case .swimming:
            return [.cyan, .blue, .teal]
        case .yoga:
            return [.purple, .pink, .indigo]
        case .functionalStrengthTraining:
            return [.red, .orange, .yellow]
        default:
            return [.green, .mint, .cyan]
        }
    }
    
    private var workoutIconColor: Color {
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
        default:
            return .green
        }
    }
    
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
        default:
            return "figure.walk.circle.fill"
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
        default:
            return "Flexible"
        }
    }
    
    private var statusText: String {
        switch workoutManager.state {
        case .notStarted: return "Not Started"
        case .running:   return "In Progress"
        case .paused:    return "Paused"
        case .prepared: return "Prepared"
        case .stopped:  return "Stopped"
        case .ended:     return "Completed"
        @unknown default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch workoutManager.state {
        case .notStarted:        return .gray
        case .running:          return .green
        case .paused:           return .yellow
        case .prepared:         return .orange
        case .stopped:          return .gray
        case .ended:            return .blue
        @unknown default:       return .gray
        }
    }
    
    // MARK: - Animation Functions
    
    private func startSessionAnimations() {
        withAnimation(.easeInOut(duration: 0.8)) {
            pulseMetrics = true
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: true)) {
            backgroundShift = 1.0
        }
        
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
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
        .preferredColorScheme(.dark)
}

