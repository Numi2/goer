import SwiftUI

// MARK: - Enhanced Glass Effect Configuration

/// Enhanced glass effect configuration with morphing capabilities
@MainActor
public struct Glass: Sendable {
    var isInteractive: Bool = false
    var tint: Color = .clear
    var intensity: Double = 1.0
    var morphStyle: MorphStyle = .subtle
    var enableFlow: Bool = true
    
    /// Glass morphing styles
    public enum MorphStyle {
        case none
        case subtle
        case moderate
        case dramatic
        
        var cornerRadiusRange: ClosedRange<CGFloat> {
            switch self {
            case .none: return 16...16
            case .subtle: return 14...18
            case .moderate: return 12...20
            case .dramatic: return 8...24
            }
        }
        
        var scaleRange: ClosedRange<CGFloat> {
            switch self {
            case .none: return 1.0...1.0
            case .subtle: return 0.99...1.01
            case .moderate: return 0.98...1.02
            case .dramatic: return 0.95...1.05
            }
        }
    }
    
    /// Creates a default enhanced glass effect
    public init() {}
    
    /// Returns a copy configured to be interactive
    public func interactive(_ enabled: Bool) -> Glass {
        var copy = self
        copy.isInteractive = enabled
        return copy
    }
    
    /// Returns a copy with the specified tint color
    public func tint(_ color: Color) -> Glass {
        var copy = self
        copy.tint = color
        return copy
    }
    
    /// Returns a copy with the specified intensity
    public func intensity(_ value: Double) -> Glass {
        var copy = self
        copy.intensity = value
        return copy
    }
    
    /// Returns a copy with the specified morph style
    public func morphStyle(_ style: MorphStyle) -> Glass {
        var copy = self
        copy.morphStyle = style
        return copy
    }
    
    /// Returns a copy with flow effect setting
    public func flow(_ enabled: Bool) -> Glass {
        var copy = self
        copy.enableFlow = enabled
        return copy
    }
}

// MARK: - Enhanced Glass Effect Container

/// Enhanced container with liquid morphing and flow effects
@MainActor @preconcurrency
public struct GlassEffectContainer<Content>: View where Content: View {
    private let spacing: CGFloat?
    private let content: () -> Content
    private let glass: Glass
    
    @State private var morphPhase: Double = 0
    @State private var isHovered: Bool = false
    
    /// Creates an enhanced glass effect container
    public init(
        spacing: CGFloat? = nil,
        glass: Glass = Glass(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.glass = glass
        self.content = content
    }
    
    public var body: some View {
        content()
            .background {
                MorphingGlassShape(
                    glass: glass,
                    morphPhase: morphPhase,
                    isInteractive: isHovered && glass.isInteractive
                )
            }
            .scaleEffect(isHovered && glass.isInteractive ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            .onAppear {
                startMorphing()
            }
    }
    
    private func startMorphing() {
        guard glass.morphStyle != .none else { return }
        
        withAnimation(
            .easeInOut(duration: 6)
            .repeatForever(autoreverses: true)
        ) {
            morphPhase = 1.0
        }
    }
}

/// Morphing glass shape with liquid properties
private struct MorphingGlassShape: View {
    let glass: Glass
    let morphPhase: Double
    let isInteractive: Bool
    
    private var cornerRadius: CGFloat {
        let range = glass.morphStyle.cornerRadiusRange
        return range.lowerBound + (range.upperBound - range.lowerBound) * morphPhase
    }
    
    private var scale: CGFloat {
        let range = glass.morphStyle.scaleRange
        return range.lowerBound + (range.upperBound - range.lowerBound) * morphPhase
    }
    
    var body: some View {
        ZStack {
            // Base glass material
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .scaleEffect(scale)
            
            // Tint overlay
            if glass.tint != .clear {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(glass.tint.opacity(0.1 * glass.intensity))
                    .scaleEffect(scale)
            }
            
            // Flow effect
            if glass.enableFlow {
                flowOverlay
                    .opacity(0.4 * glass.intensity)
            }
            
            // Interactive highlight
            if isInteractive {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .scaleEffect(scale)
            }
        }
    }
    
    private var flowOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.clear,
                        glass.tint.opacity(0.05)
                    ]),
                    startPoint: UnitPoint(
                        x: 0.3 + sin(morphPhase * .pi) * 0.4,
                        y: 0
                    ),
                    endPoint: UnitPoint(
                        x: 0.7 - sin(morphPhase * .pi) * 0.4,
                        y: 1
                    )
                )
            )
            .scaleEffect(scale)
    }
}

// MARK: - Enhanced Glass Button Style

/// Enhanced button style with liquid morphing effects
public struct LiquidGlassButtonStyle: ButtonStyle {
    let glass: Glass
    
    public init(glass: Glass = Glass().interactive(true)) {
        self.glass = glass
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                GlassEffectContainer(glass: glass) {
                    EmptyView()
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Enhanced Glass Effect Modifier

extension View {
    /// Applies enhanced glass effect with morphing capabilities
    @MainActor
    public func glassEffect(
        _ glass: Glass,
        in shape: some Shape = RoundedRectangle(cornerRadius: 16, style: .continuous),
        isEnabled: Bool = true
    ) -> some View {
        background {
            if isEnabled {
                GlassEffectContainer(glass: glass) {
                    EmptyView()
                }
            }
        }
    }
    
    /// Convenience method for quick glass effects
    public func quickGlass(
        tint: Color = .clear,
        intensity: Double = 1.0,
        interactive: Bool = false
    ) -> some View {
        glassEffect(
            Glass()
                .tint(tint)
                .intensity(intensity)
                .interactive(interactive)
        )
    }
}



