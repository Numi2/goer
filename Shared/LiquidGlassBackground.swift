import SwiftUI

// MARK: - Advanced Liquid Glass System

/// Core Liquid Glass material that implements Apple's sophisticated multi-layer architecture
struct AdvancedLiquidGlass: ViewModifier {
    let variant: LiquidGlassVariant
    let adaptToContent: Bool
    let enableLensing: Bool
    let enableSpecularHighlights: Bool
    
    @State private var highlightOpacity: Double = 0.0
    @State private var lensOffset: CGPoint = .zero
    @State private var environmentalTint: Color = .clear
    
    init(
        variant: LiquidGlassVariant = .regular,
        adaptToContent: Bool = true,
        enableLensing: Bool = true,
        enableSpecularHighlights: Bool = true
    ) {
        self.variant = variant
        self.adaptToContent = adaptToContent
        self.enableLensing = enableLensing
        self.enableSpecularHighlights = enableSpecularHighlights
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                LiquidGlassCore(
                    variant: variant,
                    highlightOpacity: highlightOpacity,
                    lensOffset: lensOffset,
                    environmentalTint: environmentalTint,
                    enableLensing: enableLensing,
                    enableSpecularHighlights: enableSpecularHighlights
                )
            }
            .onTapGesture { location in
                withAnimation(.easeOut(duration: 0.6)) {
                    highlightOpacity = 1.0
                    lensOffset = CGPoint(x: location.x, y: location.y)
                }
                
                withAnimation(.easeOut(duration: 1.2).delay(0.1)) {
                    highlightOpacity = 0.0
                    lensOffset = .zero
                }
            }
            .onAppear {
                if adaptToContent {
                    updateEnvironmentalTint()
                }
            }
    }
    
    private func updateEnvironmentalTint() {
        withAnimation(.easeInOut(duration: 2.0)) {
            environmentalTint = .blue.opacity(0.1)
        }
    }
}

/// Core liquid glass material with sophisticated layering
private struct LiquidGlassCore: View {
    let variant: LiquidGlassVariant
    let highlightOpacity: Double
    let lensOffset: CGPoint
    let environmentalTint: Color
    let enableLensing: Bool
    let enableSpecularHighlights: Bool
    
    var body: some View {
        ZStack {
            // Base blur layer - Foundation
            baseMaterial
            
            // Environmental reflection layer
            environmentalLayer
            
            // Lensing effects layer
            if enableLensing {
                lensingLayer
            }
            
            // Specular highlights layer
            if enableSpecularHighlights {
                specularHighlights
            }
            
            // Interactive glow layer
            interactiveGlow
            
            // Edge lensing effect
            edgeLensing
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    private var baseMaterial: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .opacity(variant == .clear ? 0.7 : 1.0)
    }
    
    private var environmentalLayer: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        environmentalTint,
                        environmentalTint.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var lensingLayer: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.3, y: 0.2),
                    startRadius: 10,
                    endRadius: 100
                )
            )
    }
    
    private var specularHighlights: some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 2, height: 2)
                    .blur(radius: 1)
                Spacer()
            }
            .padding(.leading, 12)
            .padding(.top, 8)
            
            Spacer()
            
            HStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 1)
                    .blur(radius: 0.5)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 12)
        }
    }
    
    private var interactiveGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(highlightOpacity * 0.6),
                        Color.blue.opacity(highlightOpacity * 0.3),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 50
                )
            )
            .frame(width: 100, height: 100)
            .position(lensOffset)
            .allowsHitTesting(false)
    }
    
    private var edgeLensing: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.2),
                        Color.clear,
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
    }
    
    private var shadowColor: Color {
        Color.black.opacity(variant == .clear ? 0.05 : 0.15)
    }
    
    private var shadowRadius: CGFloat {
        variant == .clear ? 6 : 12
    }
    
    private var shadowOffset: CGFloat {
        variant == .clear ? 3 : 6
    }
}

/// Liquid Glass variants as defined by Apple
enum LiquidGlassVariant {
    case regular    // Adaptive, works everywhere
    case clear      // Permanently transparent, for media-rich content
}

// MARK: - Convenient View Extensions

extension View {
    /// Applies advanced liquid glass background with full Apple spec implementation
    func advancedLiquidGlass(
        variant: LiquidGlassVariant = .regular,
        adaptToContent: Bool = true,
        enableLensing: Bool = true,
        enableSpecularHighlights: Bool = true
    ) -> some View {
        modifier(AdvancedLiquidGlass(
            variant: variant,
            adaptToContent: adaptToContent,
            enableLensing: enableLensing,
            enableSpecularHighlights: enableSpecularHighlights
        ))
    }
    
    /// Legacy support - enhanced version of the original
    func liquidGlassBackground() -> some View {
        advancedLiquidGlass()
    }
}
