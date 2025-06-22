/*
 Abstract:
 Advanced Liquid Glass design system implementing Apple's most sophisticated materials and interactions.
 This system creates interfaces that feel alive, responsive, and deeply integrated with user intent.
 */

import SwiftUI

// MARK: - Advanced Liquid Glass Card System

/// Ultra-sophisticated liquid glass card that implements Apple's complete design specification
private struct AdvancedLiquidGlassCard: ViewModifier {
    let tint: Color?
    let variant: LiquidGlassVariant
    let intensity: LiquidGlassIntensity
    let enableMotionEffects: Bool
    
    @State private var isPressed = false
    @State private var lightPosition: CGPoint = CGPoint(x: 0.3, y: 0.2)
    @State private var ambientGlow: Double = 0.0
    @State private var breathingScale: CGFloat = 1.0
    
    init(
        tint: Color? = nil,
        variant: LiquidGlassVariant = .regular,
        intensity: LiquidGlassIntensity = .medium,
        enableMotionEffects: Bool = true
    ) {
        self.tint = tint
        self.variant = variant
        self.intensity = intensity
        self.enableMotionEffects = enableMotionEffects
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background {
                LiquidGlassCardBackground(
                    tint: tint ?? .blue,
                    variant: variant,
                    intensity: intensity,
                    isPressed: isPressed,
                    lightPosition: lightPosition,
                    ambientGlow: ambientGlow
                )
            }
            .scaleEffect(isPressed ? 0.98 : breathingScale)
            .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isPressed)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: breathingScale)
            .onAppear {
                if enableMotionEffects {
                    startBreathingAnimation()
                    startLightMovement()
                }
            }
            .onLongPressGesture(minimumDuration: 0) { pressing in
                withAnimation(.easeOut(duration: 0.15)) {
                    isPressed = pressing
                }
            }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.01
        }
    }
    
    private func startLightMovement() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3.0)) {
                lightPosition = CGPoint(
                    x: Double.random(in: 0.2...0.8),
                    y: Double.random(in: 0.1...0.6)
                )
            }
        }
    }
}

/// Sophisticated background for liquid glass cards
private struct LiquidGlassCardBackground: View {
    let tint: Color
    let variant: LiquidGlassVariant
    let intensity: LiquidGlassIntensity
    let isPressed: Bool
    let lightPosition: CGPoint
    let ambientGlow: Double
    
    var body: some View {
        ZStack {
            // Primary material foundation
            baseMaterial
            
            // Environmental adaptation layer
            environmentalReflection
            
            // Dynamic tint layer
            tintLayer
            
            // Advanced lensing system
            advancedLensing
            
            // Specular highlight system
            specularSystem
            
            // Interactive feedback layer
            interactionFeedback
            
            // Edge definition system
            edgeSystem
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
        .overlay {
            // Additional outer glow for premium feel
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        }
    }
    
    private var baseMaterial: some View {
        Rectangle()
            .fill(variant == .clear ? .thinMaterial : .ultraThinMaterial)
            .opacity(materialOpacity)
    }
    
    private var environmentalReflection: some View {
        Rectangle()
            .fill(
                AngularGradient(
                    colors: [
                        tint.opacity(0.1),
                        Color.clear,
                        tint.opacity(0.05),
                        Color.clear
                    ],
                    center: .center,
                    angle: .degrees(45)
                )
            )
    }
    
    private var tintLayer: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        tint.opacity(tintOpacity * 0.8),
                        tint.opacity(tintOpacity * 0.4),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var advancedLensing: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.white.opacity(0.1),
                        Color.clear
                    ],
                    center: UnitPoint(x: lightPosition.x, y: lightPosition.y),
                    startRadius: 5,
                    endRadius: 80
                )
            )
    }
    
    private var specularSystem: some View {
        ZStack {
            // Primary specular highlight
            Ellipse()
                .fill(Color.white.opacity(0.6))
                .frame(width: 4, height: 2)
                .blur(radius: 1)
                .position(x: 20, y: 15)
            
            // Secondary reflection
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 2)
                .blur(radius: 1)
                .position(x: 60, y: 25)
        }
    }
    
    private var interactionFeedback: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        tint.opacity(isPressed ? 0.4 : 0.0),
                        tint.opacity(isPressed ? 0.2 : 0.0),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
    }
    
    private var edgeSystem: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(
                AngularGradient(
                    colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.3),
                        Color.clear,
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.6)
                    ],
                    center: .topLeading,
                    angle: .degrees(0)
                ),
                lineWidth: 0.8
            )
    }
    
    // Computed properties for dynamic values
    private var materialOpacity: Double {
        switch intensity {
        case .light: return variant == .clear ? 0.6 : 0.8
        case .medium: return variant == .clear ? 0.7 : 0.9
        case .heavy: return variant == .clear ? 0.8 : 1.0
        }
    }
    
    private var tintOpacity: Double {
        switch intensity {
        case .light: return 0.1
        case .medium: return 0.15
        case .heavy: return 0.2
        }
    }
    
    private var shadowColor: Color {
        Color.black.opacity(variant == .clear ? 0.08 : 0.2)
    }
    
    private var shadowRadius: CGFloat {
        switch intensity {
        case .light: return 8
        case .medium: return 16
        case .heavy: return 24
        }
    }
    
    private var shadowYOffset: CGFloat {
        switch intensity {
        case .light: return 4
        case .medium: return 8
        case .heavy: return 12
        }
    }
}

// MARK: - Advanced Button System

/// Ultra-premium liquid glass button with sophisticated interaction design
public struct AdvancedLiquidGlassButton: ButtonStyle {
    let tint: Color
    let variant: LiquidGlassVariant
    let prominence: ButtonProminence
    
    @State private var hoverEffect: Bool = false
    
    public init(
        tint: Color = .blue,
        variant: LiquidGlassVariant = .regular,
        prominence: ButtonProminence = .standard
    ) {
        self.tint = tint
        self.variant = variant
        self.prominence = prominence
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundStyle(foregroundColor(isPressed: configuration.isPressed))
            .frame(maxWidth: .infinity, minHeight: buttonHeight)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background {
                buttonBackground(isPressed: configuration.isPressed)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : (hoverEffect ? 1.02 : 1.0))
            .animation(.interpolatingSpring(stiffness: 400, damping: 25), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: hoverEffect)
            .onHover { hovering in
                hoverEffect = hovering
            }
    }
    
    private func buttonBackground(isPressed: Bool) -> some View {
        ZStack {
            // Base material
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(variant == .clear ? .thinMaterial : .regularMaterial)
            
            // Tint layer with sophisticated blending
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            tint.opacity(tintOpacity(isPressed: isPressed) * 1.2),
                            tint.opacity(tintOpacity(isPressed: isPressed) * 0.8),
                            tint.opacity(tintOpacity(isPressed: isPressed) * 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Interactive glow
            if isPressed {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
            }
            
            // Edge highlighting
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
        .shadow(
            color: tint.opacity(0.3),
            radius: isPressed ? 2 : 6,
            x: 0,
            y: isPressed ? 1 : 3
        )
    }
    
    private func foregroundColor(isPressed: Bool) -> Color {
        switch prominence {
        case .minimal:
            return .primary
        case .standard:
            return isPressed ? .white : .primary
        case .prominent:
            return .white
        }
    }
    
    private func tintOpacity(isPressed: Bool) -> Double {
        let baseOpacity: Double
        switch prominence {
        case .minimal: baseOpacity = 0.15
        case .standard: baseOpacity = 0.25
        case .prominent: baseOpacity = 0.4
        }
        
        return isPressed ? baseOpacity * 1.5 : baseOpacity
    }
    
    private var buttonHeight: CGFloat {
        switch prominence {
        case .minimal: return 40
        case .standard: return 48
        case .prominent: return 56
        }
    }
}

// MARK: - Supporting Types

enum LiquidGlassIntensity {
    case light, medium, heavy
}

enum ButtonProminence {
    case minimal, standard, prominent
}

// MARK: - App-wide Liquid Glass Theme

/// Revolutionary app-wide liquid glass styling that creates magical user experiences
private struct AdvancedLiquidGlassAppStyle: ViewModifier {
    @State private var globalAmbientLight: Double = 0.0
    
    init() {
        configureNavigationAppearance()
    }
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(AdvancedLiquidGlassButton())
            .tint(.blue)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .environment(\.liquidGlassAmbientLight, globalAmbientLight)
            .onAppear {
                startGlobalLightingEffects()
            }
    }
    
    private func configureNavigationAppearance() {
        #if canImport(UIKit)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.clear
        
        // Add subtle tint to navigation bar
        let tintedBackground = UIColor.systemBlue.withAlphaComponent(0.05)
        appearance.backgroundColor = tintedBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        #endif
    }
    
    private func startGlobalLightingEffects() {
        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
            globalAmbientLight = 1.0
        }
    }
}

// MARK: - Environment Values

private struct LiquidGlassAmbientLightKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}

extension EnvironmentValues {
    var liquidGlassAmbientLight: Double {
        get { self[LiquidGlassAmbientLightKey.self] }
        set { self[LiquidGlassAmbientLightKey.self] = newValue }
    }
}

// MARK: - Public Extensions

extension View {
    /// Applies revolutionary liquid glass card styling with advanced Apple design principles
    func advancedLiquidGlassCard(
        tint: Color? = nil,
        variant: LiquidGlassVariant = .regular,
        intensity: LiquidGlassIntensity = .medium,
        enableMotionEffects: Bool = true
    ) -> some View {
        modifier(AdvancedLiquidGlassCard(
            tint: tint,
            variant: variant,
            intensity: intensity,
            enableMotionEffects: enableMotionEffects
        ))
    }
    
    /// Legacy support with enhanced implementation
    func liquidGlassCard(tint: Color? = nil) -> some View {
        advancedLiquidGlassCard(tint: tint)
    }
    
    /// Applies the complete advanced liquid glass app styling
    func advancedLiquidGlassAppStyle() -> some View {
        modifier(AdvancedLiquidGlassAppStyle())
    }
    
    /// Legacy support - now powered by advanced system
    func liquidGlassAppStyle() -> some View {
        advancedLiquidGlassAppStyle()
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == AdvancedLiquidGlassButton {
    /// Advanced liquid glass button style with full customization
    static func advancedLiquidGlass(
        tint: Color = .blue,
        variant: LiquidGlassVariant = .regular,
        prominence: ButtonProminence = .standard
    ) -> AdvancedLiquidGlassButton {
        AdvancedLiquidGlassButton(tint: tint, variant: variant, prominence: prominence)
    }
    
    /// Convenient access to the advanced liquid glass button style
    static var advancedLiquidGlass: AdvancedLiquidGlassButton {
        AdvancedLiquidGlassButton()
    }
    
    /// Legacy support - now enhanced
    static var liquidGlass: AdvancedLiquidGlassButton {
        AdvancedLiquidGlassButton()
    }
}
