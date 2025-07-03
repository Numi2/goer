/*
 Abstract:
 Enhanced Liquid Glass design system with sophisticated glass effects, morphing, 
 and dynamic backgrounds following Apple's design principles.
 */

import SwiftUI

// MARK: - Legacy Support Types

/// Placeholder enum maintained for source-compatibility with the previous, more
/// elaborate Liquid Glass API. These cases now map to the enhanced intensity system.
public enum LiquidGlassIntensity {
    case low
    case medium
    case high
    
    var mappedIntensity: Double {
        switch self {
        case .low: return 0.6
        case .medium: return 1.0
        case .high: return 1.4
        }
    }
    
    var mappedVariant: LiquidGlassVariant {
        switch self {
        case .low: return .clear
        case .medium: return .regular
        case .high: return .prominent
        }
    }
}

// MARK: - Enhanced Extensions

extension View {
    /// Applies an enhanced glass card background with sophisticated effects
    func glassCard() -> some View {
        self
            .padding()
            .enhancedGlassCard(
                variant: .regular,
                intensity: 1.0,
                enableMorph: true
            )
    }
    
    /// Enhanced version with full configuration options
    func advancedLiquidGlassCard(
        tint: Color? = nil,
        variant: LiquidGlassVariant = .regular,
        intensity: LiquidGlassIntensity = .medium,
        enableMotionEffects: Bool = true
    ) -> some View {
        self
            .padding()
            .enhancedGlassCard(
                variant: intensity.mappedVariant,
                intensity: intensity.mappedIntensity,
                enableMorph: enableMotionEffects,
                tint: tint
            )
    }
    
    /// Legacy support with enhanced effects
    func liquidGlassCard(tint: Color? = nil) -> some View {
        self.advancedLiquidGlassCard(tint: tint)
    }
    
    /// Enhanced app styling with liquid glass button effects and dynamic backgrounds
    func advancedLiquidGlassAppStyle() -> some View {
        self
            .buttonStyle(LiquidGlassButtonStyle(
                glass: Glass()
                    .interactive(true)
                    .intensity(1.0)
                    .morphStyle(.moderate)
            ))
            .tint(.blue)
            .dynamicLiquidBackground(
                colors: [
                    Color.accentColor.opacity(0.08),
                    Color.blue.opacity(0.04),
                    Color.purple.opacity(0.02)
                ],
                intensity: 0.6
            )
    }
    
    /// Legacy support
    func liquidGlassAppStyle() -> some View {
        self.advancedLiquidGlassAppStyle()
    }
    
    /// Enhanced workout card styling for workout selection views
    func workoutCardStyle(
        isSelected: Bool = false,
        accentColor: Color = .accentColor
    ) -> some View {
        self
            .enhancedGlassCard(
                variant: isSelected ? .prominent : .regular,
                intensity: isSelected ? 1.2 : 0.8,
                enableMorph: true,
                tint: isSelected ? accentColor : .clear
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
    
    /// Enhanced metric display styling for data visualization
    func metricDisplayStyle(
        color: Color = .accentColor,
        prominence: MetricProminence = .standard
    ) -> some View {
        let glass = Glass()
            .tint(color)
            .intensity(prominence.intensity)
            .morphStyle(prominence.morphStyle)
        
        return self
            .glassEffect(glass)
    }
    
    /// Enhanced live activity styling for workout live activities
    func liveActivityStyle(workoutColor: Color = .accentColor) -> some View {
        self
            .enhancedGlassCard(
                variant: .prominent,
                intensity: 1.1,
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
}

// MARK: - Metric Prominence Levels

public enum MetricProminence {
    case minimal
    case standard
    case prominent
    case hero
    
    var intensity: Double {
        switch self {
        case .minimal: return 0.4
        case .standard: return 0.8
        case .prominent: return 1.0
        case .hero: return 1.2
        }
    }
    
    var morphStyle: Glass.MorphStyle {
        switch self {
        case .minimal: return .none
        case .standard: return .subtle
        case .prominent: return .moderate
        case .hero: return .dramatic
        }
    }
}

// MARK: - Workout Type Color Mapping

extension Color {
    /// Gets the appropriate color for a workout type
    static func workoutColor(for symbol: String) -> Color {
        switch symbol {
        case "figure.run": return .orange
        case "figure.walk": return .green
        case "bicycle": return .blue
        case "figure.pool.swim": return .cyan
        case "figure.yoga": return .purple
        case "dumbbell", "figure.strengthtraining.traditional": return .red
        case "figure.core.training": return .pink
        case "figure.flexibility": return .mint
        default: return .accentColor
        }
    }
}

