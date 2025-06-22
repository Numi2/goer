/*
 Abstract:
 Simple Liquid Glass design system following Apple's actual design principles.
 Uses system materials and minimal custom effects as recommended by Apple.
 */

import SwiftUI

// MARK: - Simple Glass Button Style

/// A clean button style that uses system materials following Apple's guidelines
public struct GlassButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Clean Extensions

extension View {
    /// Applies a simple glass card background using system materials
    func glassCard() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    /// Legacy support for existing code
    func advancedLiquidGlassCard(
        tint: Color? = nil,
        variant: LiquidGlassVariant = .regular,
        intensity: LiquidGlassIntensity = .medium,
        enableMotionEffects: Bool = true
    ) -> some View {
        self.glassCard()
    }
    
    /// Legacy support
    func liquidGlassCard(tint: Color? = nil) -> some View {
        self.glassCard()
    }
    
    /// Legacy support - now just applies clean styling
    func advancedLiquidGlassAppStyle() -> some View {
        self
            .buttonStyle(GlassButtonStyle())
            .tint(.blue)
    }
    
    /// Legacy support
    func liquidGlassAppStyle() -> some View {
        self.advancedLiquidGlassAppStyle()
    }
}

// MARK: - Supporting Types (for compatibility)

enum LiquidGlassVariant {
    case regular, clear
}

enum LiquidGlassIntensity {
    case light, medium, heavy
}

enum ButtonProminence {
    case minimal, standard, prominent
}

