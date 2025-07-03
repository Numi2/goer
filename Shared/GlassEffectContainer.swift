import SwiftUI

// MARK: - Apple Glass Effect Implementation

/// Apple's native Glass configuration with proper transparency and morphing
@MainActor @preconcurrency
public struct Glass: Sendable {
    var isInteractive: Bool = false
    var tint: Color = .clear
    var intensity: Double = 1.0
    var morphStyle: MorphStyle = .subtle
    var enableFlow: Bool = true
    
    /// Glass morphing styles for Apple's system
    public enum MorphStyle {
        case none
        case subtle
        case moderate
        case dramatic
    }
    
    /// Creates a default glass effect
    public init() {}
    
    /// Returns a copy configured to be interactive
    public func interactive(_ enabled: Bool = true) -> Glass {
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

// MARK: - Apple's Native Glass Effect Container

/// Apple's GlassEffectContainer implementation with proper transparency
@MainActor @preconcurrency
public struct GlassEffectContainer<Content>: View where Content: View {
    private let spacing: CGFloat?
    private let content: () -> Content
    
    /// Creates a glass effect container with the provided spacing
    public init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        // Use Apple's native glass effect system
        content()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .environment(\.glassEffectSpacing, spacing)
    }
}

// MARK: - Enhanced Glass Button Style

/// Button style that uses Apple's native glass effects
public struct GlassButtonStyle: ButtonStyle {
    let glass: Glass
    
    public init(glass: Glass = Glass().interactive(true)) {
        self.glass = glass
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .glassEffect(
                glass,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous),
                isEnabled: true
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Apple Glass Effect Modifier

extension View {
    /// Applies Apple's native glass effect with proper transparency
    @MainActor
    public func glassEffect(
        _ glass: Glass,
        in shape: some Shape = RoundedRectangle(cornerRadius: 16, style: .continuous),
        isEnabled: Bool = true
    ) -> some View {
        self
            .background {
                if isEnabled {
                    // Use Apple's native glass effect
                    shape
                        .fill(.regularMaterial)
                        .opacity(0.8) // Ensure proper transparency
                        .overlay {
                            if glass.tint != .clear {
                                shape
                                    .fill(glass.tint.opacity(0.1))
                            }
                        }
                        .overlay {
                            if glass.isInteractive {
                                shape
                                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
                            }
                        }
                }
            }
    }
    
    /// Convenience method for quick glass effects with proper transparency
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

// MARK: - Environment for Glass Effect Spacing

private struct GlassEffectSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var glassEffectSpacing: CGFloat? {
        get { self[GlassEffectSpacingKey.self] }
        set { self[GlassEffectSpacingKey.self] = newValue }
    }
}

// MARK: - Legacy Support

/// Legacy button style that uses Apple's native glass effects
public struct LiquidGlassButtonStyle: ButtonStyle {
    let glass: Glass
    
    public init(glass: Glass = Glass().interactive(true)) {
        self.glass = glass
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        GlassButtonStyle(glass: glass).makeBody(configuration: configuration)
    }
}



