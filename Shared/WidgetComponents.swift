/*
Abstract:
Enhanced widget components using sophisticated liquid glass design principles
with morphing effects and dynamic backgrounds.
*/

import SwiftUI

// MARK: - Enhanced Glass Card Modifier
struct EnhancedGlassCardModifier: ViewModifier {
    let variant: LiquidGlassVariant
    let intensity: Double
    let enableMorph: Bool
    let tint: Color?
    
    init(
        variant: LiquidGlassVariant = .regular,
        intensity: Double = 1.0,
        enableMorph: Bool = true,
        tint: Color? = nil
    ) {
        self.variant = variant
        self.intensity = intensity
        self.enableMorph = enableMorph
        self.tint = tint
    }
    
    func body(content: Content) -> some View {
        content
            .liquidGlass(
                variant: variant,
                intensity: intensity,
                enableGradient: true,
                adaptToContent: true
            )
    }
}

extension View {
    func enhancedGlassCard(
        variant: LiquidGlassVariant = .regular,
        intensity: Double = 1.0,
        enableMorph: Bool = true,
        tint: Color? = nil
    ) -> some View {
        modifier(EnhancedGlassCardModifier(
            variant: variant,
            intensity: intensity,
            enableMorph: enableMorph,
            tint: tint
        ))
    }
    
    // Legacy support
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        enhancedGlassCard()
    }
}

// MARK: - Enhanced Widget Header Component
struct LiquidWidgetHeader: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let variant: HeaderVariant
    
    enum HeaderVariant {
        case compact
        case expanded
        case prominent
        
        var iconSize: CGFloat {
            switch self {
            case .compact: return 16
            case .expanded: return 20
            case .prominent: return 24
            }
        }
        
        var iconFrameSize: CGFloat {
            switch self {
            case .compact: return 24
            case .expanded: return 28
            case .prominent: return 32
            }
        }
        
        var titleFont: Font {
            switch self {
            case .compact: return .system(size: 14, weight: .semibold)
            case .expanded: return .system(size: 16, weight: .semibold)
            case .prominent: return .system(size: 18, weight: .bold)
            }
        }
    }
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String? = nil,
        variant: HeaderVariant = .expanded
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.variant = variant
    }
    
    var body: some View {
        HStack {
            iconView
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(variant.titleFont)
                    .foregroundStyle(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: variant.iconSize, weight: .semibold))
            .foregroundStyle(iconColor)
            .frame(width: variant.iconFrameSize, height: variant.iconFrameSize)
            .background {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.2),
                                iconColor.opacity(0.1),
                                iconColor.opacity(0.05)
                            ],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: variant.iconFrameSize
                        )
                    )
            }
            .overlay {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [iconColor.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
    }
}

// MARK: - Enhanced Metric Display Component
struct LiquidMetricDisplay: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let layout: Layout
    let style: MetricStyle
    
    enum Layout {
        case horizontal
        case vertical
        case compact
    }
    
    enum MetricStyle {
        case standard
        case prominent
        case minimal
        
        var backgroundGlass: Glass {
            switch self {
            case .standard: return Glass().intensity(0.8)
            case .prominent: return Glass().intensity(1.0).morphStyle(.moderate)
            case .minimal: return Glass().intensity(0.5)
            }
        }
    }
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        value: String,
        layout: Layout = .horizontal,
        style: MetricStyle = .standard
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.layout = layout
        self.style = style
    }
    
    var body: some View {
        Group {
            switch layout {
            case .horizontal:
                HStack(spacing: 8) {
                    iconView
                    titleView
                    Spacer()
                    valueView
                }
            case .vertical:
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        iconView
                        titleView
                    }
                    valueView
                }
            case .compact:
                HStack(spacing: 4) {
                    iconView
                    valueView
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(style.backgroundGlass.tint(iconColor))
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(iconColor)
    }
    
    private var titleView: some View {
        Text(title)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
    }
    
    private var valueView: some View {
        Text(value)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)
    }
}

// MARK: - Enhanced Chart Bar Component
struct LiquidChartBar: View {
    let value: Double
    let maxValue: Double
    let color: Color
    let style: BarStyle
    let isActive: Bool
    
    enum BarStyle {
        case standard
        case liquid
        case gradient
        
        var cornerRadius: CGFloat {
            switch self {
            case .standard: return 2
            case .liquid: return 4
            case .gradient: return 3
            }
        }
    }
    
    @State private var animationPhase: Double = 0
    
    init(
        value: Double,
        maxValue: Double,
        color: Color,
        style: BarStyle = .liquid,
        isActive: Bool = false
    ) {
        self.value = value
        self.maxValue = max(maxValue, 1)
        self.color = color
        self.style = style
        self.isActive = isActive
    }
    
    private var normalizedHeight: CGFloat {
        CGFloat(value / maxValue)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .fill(barFill)
            .frame(height: max(2, normalizedHeight * 60))
            .frame(maxWidth: .infinity)
            .opacity(value > 0 ? 1.0 : 0.3)
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
            .onAppear {
                if style == .liquid {
                    startLiquidAnimation()
                }
            }
    }
    
    private var barFill: some ShapeStyle {
        switch style {
        case .standard:
            return AnyShapeStyle(color)
        case .liquid:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        color.opacity(0.9),
                        color,
                        color.opacity(0.8)
                    ],
                    startPoint: UnitPoint(x: 0.5 + sin(animationPhase) * 0.2, y: 0),
                    endPoint: UnitPoint(x: 0.5 - sin(animationPhase) * 0.2, y: 1)
                )
            )
        case .gradient:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [color.opacity(0.8), color],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func startLiquidAnimation() {
        withAnimation(
            .easeInOut(duration: 3)
            .repeatForever(autoreverses: true)
        ) {
            animationPhase = .pi
        }
    }
}

// MARK: - Enhanced Stat Card Component
struct LiquidStatCard: View {
    let title: String
    let value: String
    let color: Color
    let size: Size
    let variant: CardVariant
    
    enum Size {
        case small
        case medium
        case large
        
        var titleFont: Font {
            switch self {
            case .small: return .system(size: 9, weight: .medium)
            case .medium: return .system(size: 10, weight: .medium)
            case .large: return .system(size: 11, weight: .medium)
            }
        }
        
        var valueFont: Font {
            switch self {
            case .small: return .system(size: 11, weight: .bold, design: .rounded)
            case .medium: return .system(size: 12, weight: .bold, design: .rounded)
            case .large: return .system(size: 14, weight: .bold, design: .rounded)
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
            case .medium: return EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
            case .large: return EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
            }
        }
    }
    
    enum CardVariant {
        case flat
        case glass
        case prominent
        
        var glass: Glass {
            switch self {
            case .flat: return Glass().intensity(0.3)
            case .glass: return Glass().intensity(0.8).morphStyle(.subtle)
            case .prominent: return Glass().intensity(1.0).morphStyle(.moderate)
            }
        }
    }
    
    init(
        title: String,
        value: String,
        color: Color,
        size: Size = .medium,
        variant: CardVariant = .glass
    ) {
        self.title = title
        self.value = value
        self.color = color
        self.size = size
        self.variant = variant
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(size.titleFont)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            Text(value)
                .font(size.valueFont)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(size.padding)
        .glassEffect(variant.glass.tint(color))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Enhanced Chart Legend Component
struct LiquidChartLegend: View {
    let items: [LegendItem]
    let style: LegendStyle
    
    struct LegendItem {
        let color: Color
        let label: String
        let value: String?
    }
    
    enum LegendStyle {
        case minimal
        case detailed
        case prominent
    }
    
    var body: some View {
        HStack(spacing: style == .prominent ? 20 : 16) {
            ForEach(items.indices, id: \.self) { index in
                legendItem(for: items[index])
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func legendItem(for item: LegendItem) -> some View {
        HStack(spacing: 6) {
            // Indicator
            Group {
                switch style {
                case .minimal:
                    Circle()
                        .fill(item.color)
                        .frame(width: 6, height: 6)
                case .detailed:
                    RoundedRectangle(cornerRadius: 2)
                        .fill(item.color.gradient)
                        .frame(width: 8, height: 6)
                case .prominent:
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [item.color, item.color.opacity(0.7)],
                                center: .topLeading,
                                startRadius: 1,
                                endRadius: 6
                            )
                        )
                        .frame(width: 10, height: 10)
                        .overlay {
                            Circle()
                                .stroke(item.color.opacity(0.3), lineWidth: 0.5)
                        }
                }
            }
            
            // Label
            VStack(alignment: .leading, spacing: 1) {
                Text(item.label)
                    .font(.system(size: style == .prominent ? 10 : 9, weight: .medium))
                    .foregroundStyle(.secondary)
                
                if let value = item.value, style != .minimal {
                    Text(value)
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

// MARK: - Legacy Support

// Keep original components for backward compatibility
typealias WidgetHeader = LiquidWidgetHeader
typealias MetricDisplay = LiquidMetricDisplay
typealias ChartBar = LiquidChartBar
typealias StatCard = LiquidStatCard
typealias ChartLegend = LiquidChartLegend