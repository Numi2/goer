/*
 Abstract:
 Shared Liquid Glass–inspired view modifiers and utilities that modernise the UI across the app.
 */

import SwiftUI

// MARK: - Liquid Glass Card Background

/// A rounded background that mimics the system "Liquid Glass" material.
private struct LiquidGlassCard: ViewModifier {
    /// Optional tint that subtly colours the glass. Defaults to `brandAccent` at 15 % opacity.
    var tint: Color?

    func body(content: Content) -> some View {
        content
            // Put the ultra-thin material first so it acts as the main blur layer.
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            // Add an optional tint layer on top at low opacity, respecting dark/light mode.
            .background(
                (tint ?? .blue).opacity(0.15),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
    }
}

extension View {
    /// Applies a liquid-glass style, suitable for toolbars, cards or control groups.
    /// - Parameter tint: Optional tint colour. When `nil` the default `Color.brandAccent` is used.
    func liquidGlassCard(tint: Color? = nil) -> some View {
        modifier(LiquidGlassCard(tint: tint))
    }
}

// MARK: - Button Style

/// A bordered button style that sits well on top of `liquidGlassCard`.
public struct LiquidGlassButtonStyle: ButtonStyle {
    /// Tint used for the button background when pressed / prominent.
    var tint: Color = .blue

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .background(
                (configuration.isPressed ? tint.opacity(0.35) : tint.opacity(0.20)),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .foregroundStyle(.primary)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == LiquidGlassButtonStyle {
    /// Convenient access to the liquid-glass button style.
    static var liquidGlass: LiquidGlassButtonStyle { LiquidGlassButtonStyle() }
}

// MARK: - App-wide Liquid Glass theme

/// Applies sensible default styles that give the entire hierarchy a Liquid-Glass look.
private struct LiquidGlassAppStyle: ViewModifier {
    init() {
        // Adopt a transparent navigation bar with a thin blur by default for UIKit scenes.
        #if canImport(UIKit)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }

    func body(content: Content) -> some View {
        content
            // Use the custom button style everywhere unless explicitly overridden.
            .buttonStyle(.liquidGlass)
            // Provide a default accent/tint.
            .tint(.blue)
            // Apply a thin material to the navigation bar in SwiftUI scenes (iOS 17+).
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

extension View {
    /// Call this once at the root of your view hierarchy (e.g. inside `WindowGroup`) to opt the entire app into the Liquid-Glass design.
    func liquidGlassAppStyle() -> some View {
        modifier(LiquidGlassAppStyle())
    }
}
