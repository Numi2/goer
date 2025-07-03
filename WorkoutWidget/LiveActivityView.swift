/*
Abstract:
Enhanced workout Live Activity view using sophisticated liquid glass design principles
with morphing effects and dynamic backgrounds.
*/

import SwiftUI
import WidgetKit

struct LiveActivityView: View {
    @Environment(\.redactionReasons) var redactionReasons
    
    var context: ActivityViewContext<WorkoutWidgetAttributes>
    
    var body: some View {
        let metrics = context.state.metrics
        
        VStack(spacing: 20) {
            // Enhanced header with workout type and elapsed time
            HStack(alignment: .center, spacing: 16) {
                // Enhanced workout icon
                Image(systemName: context.attributes.symbol)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(workoutColor)
                    .frame(width: 48, height: 48)
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
                                    startRadius: 8,
                                    endRadius: 24
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
                
                // Enhanced elapsed time with liquid effect
                ElapsedTimeView(elapsedTime: metrics.elapsedTime)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .quickGlass(
                        tint: workoutColor,
                        intensity: 0.7,
                        interactive: false
                    )
                
                Spacer()
            }
            
            // Enhanced metrics grid with liquid glass cards
            if metrics.activeEnergy != nil {
                HStack(spacing: 12) {
                    // Heart Rate
                    EnhancedMetricItem(
                        icon: "heart.fill",
                        iconColor: .red,
                        value: redactionReasons.contains(.privacy) ? "--" : metrics.getHeartRate(),
                        title: "BPM"
                    )
                    
                    // Distance (if supported)
                    if metrics.supportsDistance {
                        EnhancedMetricItem(
                            icon: "location.fill",
                            iconColor: .green,
                            value: redactionReasons.contains(.privacy) ? "--" : metrics.getDistance(),
                            title: "Distance"
                        )
                    }
                    
                    // Active Energy
                    EnhancedMetricItem(
                        icon: "flame.fill",
                        iconColor: .orange,
                        value: redactionReasons.contains(.privacy) ? "--" : metrics.getActiveEnergy(),
                        title: "Cal"
                    )
                }
            }
        }
        .padding()
        .enhancedGlassCard(
            variant: .prominent,
            intensity: 1.0,
            enableMorph: true,
            tint: workoutColor
        )
        .dynamicLiquidBackground(
            colors: [
                workoutColor.opacity(0.2),
                Color.blue.opacity(0.1),
                workoutColor.opacity(0.05)
            ],
            intensity: 0.8
        )
    }
    
    private var workoutColor: Color {
        // Map the workout type to appropriate colors
        let symbol = context.attributes.symbol
        switch symbol {
        case "figure.run": return .orange
        case "figure.walk": return .green
        case "bicycle": return .blue
        case "figure.pool.swim": return .cyan
        case "figure.yoga": return .purple
        case "dumbbell": return .red
        default: return .accentColor
        }
    }
}

private struct EnhancedMetricItem: View {
    let icon: String
    let iconColor: Color
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Enhanced icon with gradient background
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    iconColor.opacity(0.2),
                                    iconColor.opacity(0.1),
                                    iconColor.opacity(0.05)
                                ],
                                center: .topLeading,
                                startRadius: 4,
                                endRadius: 16
                            )
                        )
                }
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [iconColor.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .quickGlass(
            tint: iconColor,
            intensity: 0.6,
            interactive: false
        )
    }
}
