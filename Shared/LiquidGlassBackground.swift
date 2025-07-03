import SwiftUI

// MARK: - Enhanced Liquid Glass System

/// Enhanced liquid glass modifier with sophisticated morphology and gradients
struct EnhancedLiquidGlass: ViewModifier {
    let variant: LiquidGlassVariant
    let intensity: Double
    let enableGradient: Bool
    let adaptToContent: Bool
    
    init(
        variant: LiquidGlassVariant = .regular,
        intensity: Double = 1.0,
        enableGradient: Bool = true,
        adaptToContent: Bool = true
    ) {
        self.variant = variant
        self.intensity = intensity
        self.enableGradient = enableGradient
        self.adaptToContent = adaptToContent
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                LiquidGlassShape(
                    variant: variant,
                    intensity: intensity,
                    enableGradient: enableGradient
                )
            }
    }
}

/// Advanced liquid glass shape with morphing capabilities
struct LiquidGlassShape: View {
    let variant: LiquidGlassVariant
    let intensity: Double
    let enableGradient: Bool
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base glass layer
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(baseMaterial)
            
            // Gradient overlay for depth
            if enableGradient {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(gradientOverlay)
                    .opacity(0.6 * intensity)
            }
            
            // Liquid flow effect
            liquidFlowOverlay
                .opacity(0.3 * intensity)
            
            // Subtle border enhancement
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(borderGradient, lineWidth: 0.5)
                .opacity(0.4)
        }
        .onAppear {
            startLiquidAnimation()
        }
    }
    
    private var baseMaterial: Material {
        switch variant {
        case .regular: return .ultraThinMaterial
        case .clear: return .thinMaterial
        case .thick: return .regularMaterial
        case .prominent: return .thickMaterial
        }
    }
    
    private var gradientOverlay: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.2),
                Color.clear,
                Color.black.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var liquidFlowOverlay: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.accentColor.opacity(0.1),
                        Color.clear,
                        Color.accentColor.opacity(0.05)
                    ]),
                    startPoint: UnitPoint(x: 0.5 + animationOffset, y: 0),
                    endPoint: UnitPoint(x: 0.5 - animationOffset, y: 1)
                )
            )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.3),
                Color.clear,
                Color.white.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func startLiquidAnimation() {
        withAnimation(
            .easeInOut(duration: 4)
            .repeatForever(autoreverses: true)
        ) {
            animationOffset = 0.3
        }
    }
}

/// Enhanced Liquid Glass variants
enum LiquidGlassVariant {
    case regular    // Standard system material with enhancement
    case clear      // Minimal material for content-rich areas
    case thick      // More pronounced glass effect
    case prominent  // Maximum glass effect for focal elements
}

// MARK: - Dynamic Liquid Background

/// Dynamic liquid background that flows and adapts
struct DynamicLiquidBackground: View {
    let colors: [Color]
    let intensity: Double
    
    @State private var phase: Double = 0
    
    init(
        colors: [Color] = [.accentColor.opacity(0.3), .blue.opacity(0.2), .purple.opacity(0.1)],
        intensity: Double = 1.0
    ) {
        self.colors = colors
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            // Animated gradient layers
            ForEach(0..<colors.count, id: \.self) { index in
                AnimatedGradientLayer(
                    color: colors[index],
                    phase: phase + Double(index) * 0.5,
                    intensity: intensity
                )
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 8)
                .repeatForever(autoreverses: false)
            ) {
                phase = .pi * 2
            }
        }
    }
}

private struct AnimatedGradientLayer: View {
    let color: Color
    let phase: Double
    let intensity: Double
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.4 * intensity),
                        color.opacity(0.1 * intensity),
                        Color.clear
                    ]),
                    center: UnitPoint(
                        x: 0.5 + cos(phase) * 0.3,
                        y: 0.5 + sin(phase * 1.3) * 0.2
                    ),
                    startRadius: 50,
                    endRadius: 300
                )
            )
            .blur(radius: 30)
            .scaleEffect(1.2 + sin(phase) * 0.1)
    }
}

// MARK: - Enhanced View Extensions

extension View {
    /// Applies enhanced liquid glass background with sophisticated effects
    func liquidGlass(
        variant: LiquidGlassVariant = .regular,
        intensity: Double = 1.0,
        enableGradient: Bool = true,
        adaptToContent: Bool = true
    ) -> some View {
        modifier(EnhancedLiquidGlass(
            variant: variant,
            intensity: intensity,
            enableGradient: enableGradient,
            adaptToContent: adaptToContent
        ))
    }
    
    /// Applies a dynamic liquid background
    func dynamicLiquidBackground(
        colors: [Color] = [.accentColor.opacity(0.3), .blue.opacity(0.2), .purple.opacity(0.1)],
        intensity: Double = 1.0
    ) -> some View {
        background {
            DynamicLiquidBackground(colors: colors, intensity: intensity)
        }
    }
    
    /// Legacy support - now uses enhanced system
    func advancedLiquidGlass(
        variant: LiquidGlassVariant = .regular,
        adaptToContent: Bool = true,
        enableLensing: Bool = true,
        enableSpecularHighlights: Bool = true
    ) -> some View {
        self.liquidGlass(
            variant: variant,
            intensity: enableSpecularHighlights ? 1.0 : 0.7,
            enableGradient: enableLensing,
            adaptToContent: adaptToContent
        )
    }
    
    /// Legacy support
    func liquidGlassBackground() -> some View {
        self.liquidGlass()
    }
}
