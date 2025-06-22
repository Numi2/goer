/*
 Abstract:
 Simple Liquid Glass design system following Apple's actual design principles.
 Uses system materials and minimal custom effects as recommended by Apple.
 */

import SwiftUI

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

enum LiquidGlassIntensity {
    case light, medium, heavy
}

enum ButtonProminence {
    case minimal, standard, prominent
}

