/*
Abstract:
Shared components for widgets following Apple's Liquid Glass design principles.
*/

import SwiftUI

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Widget Header Component
struct WidgetHeader: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    
    init(icon: String, iconColor: Color, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
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
}

// MARK: - Metric Display Component
struct MetricDisplay: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let layout: Layout
    
    enum Layout {
        case horizontal
        case vertical
    }
    
    init(icon: String, iconColor: Color, title: String, value: String, layout: Layout = .horizontal) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.layout = layout
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
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        iconView
                        titleView
                    }
                    valueView
                }
            }
        }
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(iconColor)
    }
    
    private var titleView: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
    }
    
    private var valueView: some View {
        Text(value)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)
    }
}

// MARK: - Chart Bar Component
struct ChartBar: View {
    let value: Double
    let maxValue: Double
    let color: Color
    let cornerRadius: CGFloat
    let minHeight: CGFloat
    
    init(
        value: Double,
        maxValue: Double,
        color: Color,
        cornerRadius: CGFloat = 2,
        minHeight: CGFloat = 2
    ) {
        self.value = value
        self.maxValue = max(maxValue, 1) // Prevent division by zero
        self.color = color
        self.cornerRadius = cornerRadius
        self.minHeight = minHeight
    }
    
    private var normalizedHeight: CGFloat {
        CGFloat(value / maxValue)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color.gradient)
            .opacity(value > 0 ? 1.0 : 0.3)
            .frame(height: max(minHeight, normalizedHeight * 60))
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let size: Size
    
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
            case .small: return EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
            case .medium: return EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
            case .large: return EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
            }
        }
    }
    
    init(title: String, value: String, color: Color, size: Size = .medium) {
        self.title = title
        self.value = value
        self.color = color
        self.size = size
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
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Chart Legend Component
struct ChartLegend: View {
    let items: [LegendItem]
    
    struct LegendItem {
        let color: Color
        let label: String
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(items.indices, id: \.self) { index in
                HStack(spacing: 4) {
                    Circle()
                        .fill(items[index].color)
                        .frame(width: 6, height: 6)
                    
                    Text(items[index].label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}