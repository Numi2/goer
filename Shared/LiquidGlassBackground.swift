import SwiftUI

struct LiquidGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.25), Color.blue.opacity(0.15)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
    }
}

extension View {
    func liquidGlassBackground() -> some View {
        modifier(LiquidGlassBackground())
    }
}
