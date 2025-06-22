import SwiftUI

// MARK: - Simple Glass Effect Configuration

/// A simple glass effect configuration
@MainActor
public struct Glass: Sendable {
    var isInteractive: Bool = false
    var tint: Color = .clear
    var intensity: Double = 1.0
    
    /// Creates a default glass effect
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
}

// MARK: - Simple Glass Effect Container

/// A clean container that simply displays content without complex morphing
@MainActor @preconcurrency
public struct GlassEffectContainer<Content>: View where Content: View {
    private let spacing: CGFloat?
    private let content: () -> Content
    
    /// Creates a simple glass effect container
    public init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        content()
    }
}

// MARK: - Simple Glass Button Style

/// A clean button style using system materials
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

// MARK: - Glass Effect Modifier

extension View {
    /// Applies a simple glass effect using system materials
    @MainActor
    public func glassEffect(_ glass: Glass, in shape: some Shape, isEnabled: Bool = true) -> some View {
        self.background(
            .ultraThinMaterial,
            in: shape
        )
    }
}



