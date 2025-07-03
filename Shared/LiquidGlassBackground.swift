import SwiftUI

// MARK: - Apple Native Glass System

/// Apple's native glass modifier with proper transparency and morphing
struct AppleGlassModifier: ViewModifier {
    let variant: GlassVariant
    let intensity: Double
    let enableMorph: Bool
    let tintColor: Color
    
    init(
        variant: GlassVariant = .regular,
        intensity: Double = 1.0,
        enableMorph: Bool = true,
        tintColor: Color = .clear
    ) {
        self.variant = variant
        self.intensity = intensity
        self.enableMorph = enableMorph
        self.tintColor = tintColor
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                GlassEffectContainer(spacing: enableMorph ? 8 : nil) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(variant.material)
                        .opacity(0.8 * intensity) // Ensure proper transparency
                        .overlay {
                            if tintColor != .clear {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(tintColor)
                                    .opacity(0.1 * intensity)
                            }
                        }
                        .overlay {
                            // Subtle highlight for depth
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                                .opacity(0.6)
                        }
                }
            }
    }
}

/// Apple's native glass variants with proper material usage
enum GlassVariant {
    case ultraThin    // Most transparent
    case thin         // Light transparency
    case regular      // Standard transparency
    case thick        // Heavy transparency
    case prominent    // Maximum glass effect
    
    var material: Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .thin: return .thinMaterial
        case .regular: return .regularMaterial
        case .thick: return .thickMaterial
        case .prominent: return .thickMaterial
        }
    }
}

// MARK: - Enhanced Glass Card

/// Enhanced glass card using Apple's native glass effects
struct AppleGlassCard: ViewModifier {
    let variant: GlassVariant
    let intensity: Double
    let enableMorph: Bool
    let tint: Color
    
    init(
        variant: GlassVariant = .regular,
        intensity: Double = 1.0,
        enableMorph: Bool = true,
        tint: Color? = nil
    ) {
        self.variant = variant
        self.intensity = intensity
        self.enableMorph = enableMorph
        self.tint = tint ?? .clear
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                GlassEffectContainer(spacing: enableMorph ? 12 : nil) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(variant.material)
                        .opacity(0.9 * intensity) // Proper transparency for cards
                        .overlay {
                            if tint != .clear {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(tint)
                                    .opacity(0.08 * intensity)
                            }
                        }
                        .overlay {
                            // Card border for definition
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        }
                }
            }
    }
}

// MARK: - Dynamic Background with Apple Glass

/// Dynamic background that uses Apple's native glass system
struct AppleDynamicBackground: View {
    let colors: [Color]
    let intensity: Double
    
    @State private var phase: Double = 0
    
    init(
        colors: [Color] = [.accentColor.opacity(0.1), .blue.opacity(0.05)],
        intensity: Double = 0.5
    ) {
        self.colors = colors
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            // Base glass background
            GlassEffectContainer(spacing: 16) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            }
            
            // Animated color layers
            ForEach(0..<colors.count, id: \.self) { index in
                AnimatedColorLayer(
                    color: colors[index],
                    phase: phase + Double(index) * 0.7,
                    intensity: intensity
                )
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 12)
                .repeatForever(autoreverses: false)
            ) {
                phase = .pi * 2
            }
        }
    }
}

private struct AnimatedColorLayer: View {
    let color: Color
    let phase: Double
    let intensity: Double
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.3 * intensity),
                        color.opacity(0.1 * intensity),
                        Color.clear
                    ]),
                    center: UnitPoint(
                        x: 0.5 + cos(phase) * 0.2,
                        y: 0.5 + sin(phase * 1.2) * 0.15
                    ),
                    startRadius: 100,
                    endRadius: 400
                )
            )
            .blur(radius: 40)
            .scaleEffect(1.1 + sin(phase) * 0.05)
    }
}

// MARK: - Enhanced View Extensions

extension View {
    /// Applies Apple's native glass background with proper transparency
    func appleGlass(
        variant: GlassVariant = .regular,
        intensity: Double = 1.0,
        enableMorph: Bool = true,
        tintColor: Color = .clear
    ) -> some View {
        modifier(AppleGlassModifier(
            variant: variant,
            intensity: intensity,
            enableMorph: enableMorph,
            tintColor: tintColor
        ))
    }
    
    /// Applies dynamic background using Apple's glass system
    func appleDynamicBackground(
        colors: [Color] = [.accentColor.opacity(0.1), .blue.opacity(0.05)],
        intensity: Double = 0.5
    ) -> some View {
        background {
            AppleDynamicBackground(colors: colors, intensity: intensity)
        }
    }
    
    /// Legacy support - updated to use Apple's system
    func liquidGlass(
        variant: LiquidGlassVariant = .regular,
        intensity: Double = 1.0,
        enableGradient: Bool = true,
        adaptToContent: Bool = true
    ) -> some View {
        self.appleGlass(
            variant: variant.toGlassVariant(),
            intensity: intensity,
            enableMorph: enableGradient,
            tintColor: .clear
        )
    }
    
    /// Legacy support
    func dynamicLiquidBackground(
        colors: [Color] = [.accentColor.opacity(0.1), .blue.opacity(0.05)],
        intensity: Double = 0.5
    ) -> some View {
        self.appleDynamicBackground(colors: colors, intensity: intensity)
    }
    
    /// Legacy support
    func advancedLiquidGlass(
        variant: LiquidGlassVariant = .regular,
        adaptToContent: Bool = true,
        enableLensing: Bool = true,
        enableSpecularHighlights: Bool = true
    ) -> some View {
        self.appleGlass(
            variant: variant.toGlassVariant(),
            intensity: enableSpecularHighlights ? 1.0 : 0.7,
            enableMorph: enableLensing,
            tintColor: .clear
        )
    }
    
    /// Legacy support
    func liquidGlassBackground() -> some View {
        self.appleGlass()
    }
}

// MARK: - Legacy Support Types

/// Legacy enum for backward compatibility
enum LiquidGlassVariant {
    case regular
    case clear
    case thick
    case prominent
    
    func toGlassVariant() -> GlassVariant {
        switch self {
        case .regular: return .regular
        case .clear: return .thin
        case .thick: return .thick
        case .prominent: return .prominent
        }
    }
}

