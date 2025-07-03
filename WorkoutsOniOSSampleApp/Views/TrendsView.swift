/*
Abstract:
Trends view for displaying historical activity data and analytics.
*/

import SwiftUI

struct TrendsView: View {
    @Environment(ActivityMonitor.self) private var activityMonitor
    @Environment(StepTracker.self) private var stepTracker
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Time Range Picker
                timeRangePicker
                
                // Activity Summary
                activitySummarySection
                
                // Step Trends
                stepTrendsSection
                
                // Health Trends
                healthTrendsSection
                
                // Activity Patterns
                activityPatternsSection
            }
            .padding()
        }
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Activity Summary Section
    
    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                TrendSummaryCard(
                    icon: "figure.walk",
                    iconColor: .blue,
                    title: "Average Steps",
                    value: "8,543",
                    change: "+12%",
                    isPositive: true
                )
                
                TrendSummaryCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Avg Calories",
                    value: "387",
                    change: "+5%",
                    isPositive: true
                )
                
                TrendSummaryCard(
                    icon: "location.fill",
                    iconColor: .green,
                    title: "Avg Distance",
                    value: "6.2 km",
                    change: "-2%",
                    isPositive: false
                )
                
                TrendSummaryCard(
                    icon: "clock.fill",
                    iconColor: .purple,
                    title: "Active Minutes",
                    value: "45 min",
                    change: "+8%",
                    isPositive: true
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Step Trends Section
    
    private var stepTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step Trends")
                .font(.title2)
                .fontWeight(.bold)
            
            // Placeholder chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .frame(height: 200)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                        
                        Text("Step Trend Chart")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Historical step data visualization will appear here")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            
            Text("Your step count has been trending upward over the past \(selectedTimeRange.rawValue.lowercased()). Keep up the great work!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Health Trends Section
    
    private var healthTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Trends")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                HealthTrendCard(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Resting Heart Rate",
                    value: "64 BPM",
                    trend: "Stable",
                    trendColor: .green
                )
                
                HealthTrendCard(
                    icon: "waveform.path.ecg",
                    iconColor: .blue,
                    title: "HRV",
                    value: "42 ms",
                    trend: "Improving",
                    trendColor: .green
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Activity Patterns Section
    
    private var activityPatternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Patterns")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                PatternInsightRow(
                    icon: "sun.max.fill",
                    iconColor: .yellow,
                    title: "Most Active Time",
                    value: "10:00 AM - 11:00 AM",
                    description: "You tend to be most active during late morning hours"
                )
                
                PatternInsightRow(
                    icon: "calendar",
                    iconColor: .blue,
                    title: "Most Active Day",
                    value: "Tuesday",
                    description: "Tuesdays show your highest activity levels"
                )
                
                PatternInsightRow(
                    icon: "moon.fill",
                    iconColor: .purple,
                    title: "Least Active Time",
                    value: "2:00 PM - 4:00 PM",
                    description: "Consider a short walk during afternoon hours"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Supporting Views

struct TrendSummaryCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconColor)
                
                Spacer()
                
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isPositive ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct HealthTrendCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let trend: String
    let trendColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconColor)
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(trendColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PatternInsightRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        TrendsView()
    }
    .environment(ActivityMonitor.shared)
    .environment(StepTracker.shared)
}