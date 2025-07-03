/*
 Abstract:
 Apple Native Glass design system with proper transparency and morphing
 using Apple's SwiftUI glass effects APIs.
 */

import SwiftUI

// MARK: - Apple Native Glass Extensions

extension View {
    /// Applies Apple's native glass card background with proper transparency
    func glassCard() -> some View {
        self
            .padding()
            .enhancedGlassCard(
                variant: .regular,
                intensity: 1.0,
                enableMorph: true
            )
    }
    
    /// Advanced glass card with Apple's native system
    func advancedGlassCard(
        tint: Color? = nil,
        variant: GlassVariant = .regular,
        intensity: GlassIntensity = .medium,
        enableMotionEffects: Bool = true
    ) -> some View {
        self
            .padding()
            .enhancedGlassCard(
                variant: variant,
                intensity: intensity.mappedIntensity,
                enableMorph: enableMotionEffects,
                tint: tint
            )
    }
    
    /// Apple's native glass app styling with proper transparency
    func appleGlassAppStyle() -> some View {
        self
            .buttonStyle(GlassButtonStyle(
                glass: Glass()
                    .interactive(true)
                    .intensity(1.0)
                    .morphStyle(.moderate)
            ))
            .tint(.blue)
            .appleDynamicBackground(
                colors: [
                    Color.accentColor.opacity(0.04),
                    Color.blue.opacity(0.02),
                    Color.purple.opacity(0.01)
                ],
                intensity: 0.3
            )
    }
    
    /// Enhanced workout card with Apple's native glass morphing
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
    
    /// Apple's native metric display with proper glass effects
    func metricDisplayStyle(
        color: Color = .accentColor,
        prominence: MetricProminence = .standard
    ) -> some View {
        let glass = Glass()
            .tint(color)
            .intensity(prominence.intensity)
            .morphStyle(prominence.morphStyle)
        
        return self
            .glassEffect(glass, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    /// Enhanced live activity with Apple's native glass system
    func liveActivityStyle(workoutColor: Color = .accentColor) -> some View {
        self
            .enhancedGlassCard(
                variant: .prominent,
                intensity: 1.1,
                enableMorph: true,
                tint: workoutColor
            )
            .appleDynamicBackground(
                colors: [
                    workoutColor.opacity(0.1),
                    Color.blue.opacity(0.05),
                    workoutColor.opacity(0.02)
                ],
                intensity: 0.4
            )
    }
    
    // MARK: - Legacy Support Methods
    
    /// Legacy support - uses Apple's native system
    func liquidGlassCard(tint: Color? = nil) -> some View {
        self.advancedGlassCard(tint: tint)
    }
    
    /// Legacy support - uses Apple's native system
    func advancedLiquidGlassCard(
        tint: Color? = nil,
        variant: LiquidGlassVariant = .regular,
        intensity: LiquidGlassIntensity = .medium,
        enableMotionEffects: Bool = true
    ) -> some View {
        self.advancedGlassCard(
            tint: tint,
            variant: variant.toGlassVariant(),
            intensity: intensity.toGlassIntensity(),
            enableMotionEffects: enableMotionEffects
        )
    }
    
    /// Legacy support - uses Apple's native system
    func liquidGlassAppStyle() -> some View {
        self.appleGlassAppStyle()
    }
    
    /// Legacy support - uses Apple's native system  
    func advancedLiquidGlassAppStyle() -> some View {
        self.appleGlassAppStyle()
    }
}

// MARK: - Glass Intensity Mapping

/// Glass intensity levels for Apple's native system
public enum GlassIntensity {
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

// MARK: - Legacy Support Types

/// Legacy enum for backward compatibility
public enum LiquidGlassIntensity {
    case low
    case medium
    case high
    
    func toGlassIntensity() -> GlassIntensity {
        switch self {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        }
    }
}

