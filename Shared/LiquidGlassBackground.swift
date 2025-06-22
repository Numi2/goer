import SwiftUI

// MARK: - Simple Liquid Glass System

/// Simple liquid glass modifier that uses system materials following Apple's guidelines
struct SimpleLiquidGlass: ViewModifier {
    let variant: LiquidGlassVariant
    
    init(variant: LiquidGlassVariant = .regular) {
        self.variant = variant
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                material,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }
    
    private var material: Material {
        switch variant {
        case .regular: return .ultraThinMaterial
        case .clear: return .thinMaterial
        }
    }
}

/// Liquid Glass variants as defined by Apple
enum LiquidGlassVariant {
    case regular    // Standard system material
    case clear      // Thinner material for media-rich content
}

// MARK: - Clean View Extensions

extension View {
    /// Applies simple liquid glass background using system materials
    func liquidGlass(variant: LiquidGlassVariant = .regular) -> some View {
        modifier(SimpleLiquidGlass(variant: variant))
    }
    
    /// Legacy support - now uses simple system implementation
    func advancedLiquidGlass(
        variant: LiquidGlassVariant = .regular,
        adaptToContent: Bool = true,
        enableLensing: Bool = true,
        enableSpecularHighlights: Bool = true
    ) -> some View {
        self.liquidGlass(variant: variant)
    }
    
    /// Legacy support
    func liquidGlassBackground() -> some View {
        self.liquidGlass()
    }
}
