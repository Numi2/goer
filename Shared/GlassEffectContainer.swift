import SwiftUI

// MARK: - Glass Effect Configuration

/// A structure that defines the glass effect properties
@MainActor
public struct Glass: Sendable {
    private var isInteractive: Bool = false
    private var tint: Color = .clear
    private var intensity: Double = 1.0
    
    /// Creates a default glass effect
    public init() {}
    
    /// Returns a copy of the structure configured to be interactive
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

// MARK: - Glass Effect Container

/// A view that combines multiple Liquid Glass shapes into a single shape that can morph individual shapes into one another.
@MainActor @preconcurrency
public struct GlassEffectContainer<Content>: View where Content: View {
    private let spacing: CGFloat?
    private let content: () -> Content
    
    @State private var glassShapes: [GlassShapeInfo] = []
    @State private var morphAnimation: Bool = false
    
    /// Creates a glass effect container with the provided spacing, extracting glass shapes from the provided content.
    public init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            // Background morphing glass layer
            ForEach(glassShapes) { shapeInfo in
                GlassMorphingShape(
                    shapeInfo: shapeInfo,
                    spacing: spacing ?? 20,
                    morphAnimation: morphAnimation
                )
            }
            
            // Content layer
            content()
                .onPreferenceChange(GlassShapePreferenceKey.self) { shapes in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.glassShapes = shapes
                    }
                }
        }
        .onAppear {
            startMorphingAnimation()
        }
    }
    
    private func startMorphingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            morphAnimation = true
        }
    }
}

// MARK: - Glass Effect Transition

/// A structure that describes changes to apply when a glass effect is added or removed from the view hierarchy.
public struct GlassEffectTransition: Sendable {
    private let type: TransitionType
    private let properties: MatchedGeometryProperties
    private let anchor: UnitPoint
    
    private enum TransitionType {
        case identity
        case matchedGeometry
    }
    
    private init(type: TransitionType, properties: MatchedGeometryProperties = .frame, anchor: UnitPoint = .center) {
        self.type = type
        self.properties = properties
        self.anchor = anchor
    }
    
    /// The identity transition specifying no changes.
    public static var identity: GlassEffectTransition {
        GlassEffectTransition(type: .identity)
    }
    
    /// Returns the matched geometry glass effect transition.
    public static var matchedGeometry: GlassEffectTransition {
        GlassEffectTransition(type: .matchedGeometry)
    }
    
    /// Returns the matched geometry glass effect transition.
    public static func matchedGeometry(properties: MatchedGeometryProperties, anchor: UnitPoint) -> GlassEffectTransition {
        GlassEffectTransition(type: .matchedGeometry, properties: properties, anchor: anchor)
    }
}

// MARK: - Glass Button Style

/// A button style that applies glass border artwork based on the button's context.
public struct GlassButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                GlassButtonBackground(isPressed: configuration.isPressed)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.interpolatingSpring(stiffness: 400, damping: 25), value: configuration.isPressed)
    }
}

// MARK: - Glass Effect Modifier

extension View {
    /// Applies the Liquid Glass effect to a view.
    @MainActor
    public func glassEffect(_ glass: Glass, in shape: some Shape, isEnabled: Bool = true) -> some View {
        self.modifier(GlassEffectModifier(glass: glass, shape: shape, isEnabled: isEnabled))
    }
}

// MARK: - Private Implementation Details

private struct GlassEffectModifier<S: Shape>: ViewModifier {
    let glass: Glass
    let shape: S
    let isEnabled: Bool
    
    @State private var id = UUID()
    @State private var touchLocation: CGPoint? = nil
    
    func body(content: Content) -> some View {
        content
            .background(alignment: .center) {
                if isEnabled {
                    GlassEffectView(
                        glass: glass,
                        shape: shape,
                        touchLocation: touchLocation
                    )
                    .allowsHitTesting(false)
                }
            }
            .onTapGesture { location in
                if glass.isInteractive {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        touchLocation = location
                    }
                    
                    withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                        touchLocation = nil
                    }
                }
            }
            .preference(key: GlassShapePreferenceKey.self, value: [
                GlassShapeInfo(id: id, shape: AnyShape(shape), glass: glass)
            ])
    }
}

private struct GlassEffectView<S: Shape>: View {
    let glass: Glass
    let shape: S
    let touchLocation: CGPoint?
    
    var body: some View {
        shape
            .fill(.ultraThinMaterial)
            .overlay {
                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                glass.tint.opacity(0.3 * glass.intensity),
                                glass.tint.opacity(0.1 * glass.intensity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                if let location = touchLocation {
                    shape
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                center: UnitPoint(x: location.x / 200, y: location.y / 200),
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                }
            }
            .overlay {
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: glass.tint.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

private struct GlassMorphingShape: View {
    let shapeInfo: GlassShapeInfo
    let spacing: CGFloat
    let morphAnimation: Bool
    
    @State private var morphOffset: CGFloat = 0
    
    var body: some View {
        shapeInfo.shape
            .fill(.ultraThinMaterial)
            .scaleEffect(morphAnimation ? 1.02 : 1.0)
            .offset(x: morphOffset * sin(morphAnimation ? .pi : 0),
                    y: morphOffset * cos(morphAnimation ? .pi : 0))
            .onAppear {
                morphOffset = CGFloat.random(in: -5...5)
            }
    }
}

private struct GlassButtonBackground: View {
    let isPressed: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(isPressed ? 0.4 : 0.2),
                                Color.blue.opacity(isPressed ? 0.2 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: .blue.opacity(isPressed ? 0.1 : 0.3), radius: isPressed ? 2 : 8, x: 0, y: isPressed ? 1 : 4)
    }
}

// MARK: - Shape Preference Key

private struct GlassShapeInfo: Identifiable {
    let id: UUID
    let shape: AnyShape
    let glass: Glass
}

private struct GlassShapePreferenceKey: PreferenceKey {
    static var defaultValue: [GlassShapeInfo] = []
    
    static func reduce(value: inout [GlassShapeInfo], nextValue: () -> [GlassShapeInfo]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Type-Erased Shape

private struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}