/*
Abstract:
Clean workout Live Activity view following Apple's Liquid Glass design principles.
*/

import SwiftUI
import WidgetKit

struct LiveActivityView: View {
    @Environment(\.redactionReasons) var redactionReasons
    
    var context: ActivityViewContext<WorkoutWidgetAttributes>
    
    var body: some View {
        let metrics = context.state.metrics
        
        VStack(spacing: 16) {
            // Header with workout type and elapsed time
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: context.attributes.symbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(workoutColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(workoutColor.opacity(0.15))
                    )
                
                ElapsedTimeView(elapsedTime: metrics.elapsedTime)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            // Metrics grid
            if metrics.activeEnergy != nil {
                HStack(spacing: 16) {
                    // Heart Rate
                    MetricItem(
                        icon: "heart.fill",
                        iconColor: .red,
                        value: redactionReasons.contains(.privacy) ? "--" : metrics.getHeartRate()
                    )
                    
                    // Distance (if supported)
                    if metrics.supportsDistance {
                        MetricItem(
                            icon: "location.fill",
                            iconColor: .green,
                            value: redactionReasons.contains(.privacy) ? "--" : metrics.getDistance()
                        )
                    }
                    
                    // Active Energy
                    MetricItem(
                        icon: "flame.fill",
                        iconColor: .orange,
                        value: redactionReasons.contains(.privacy) ? "--" : metrics.getActiveEnergy()
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var workoutColor: Color {
        // Map workout symbols to colors (simple heuristics)
        switch context.attributes.symbol {
        case let symbol if symbol.contains("run"): return .orange
        case let symbol if symbol.contains("walk"): return .green
        case let symbol if symbol.contains("cycle"): return .blue
        case let symbol if symbol.contains("swim"): return .cyan
        case let symbol if symbol.contains("yoga"): return .purple
        case let symbol if symbol.contains("strength"): return .red
        default: return .blue
        }
    }
}

private struct MetricItem: View {
    let icon: String
    let iconColor: Color
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
