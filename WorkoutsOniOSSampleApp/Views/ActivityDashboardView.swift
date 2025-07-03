/*
Abstract:
Main activity dashboard view that provides a comprehensive overview of daily activity
and health metrics without requiring explicit workout sessions. This replaces the
workout-centric StartView with a passive monitoring approach.
*/

import SwiftUI

struct ActivityDashboardView: View {
    @Environment(ActivityMonitor.self) private var activityMonitor
    @State private var showingGoalSettings = false
    @State private var showingHealthDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Activity Rings Section
                    activityRingsSection
                    
                    // Today's Metrics
                    dailyMetricsSection
                    
                    // Health Metrics
                    healthMetricsSection
                    
                    // Activity Level & Insights
                    activityInsightsSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activityMonitor.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .refreshable {
                activityMonitor.refresh()
            }
        }
        .sheet(isPresented: $showingGoalSettings) {
            GoalSettingsView()
        }
        .sheet(isPresented: $showingHealthDetails) {
            HealthDetailsView()
        }
    }
    
    // MARK: - Activity Rings Section
    
    private var activityRingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity Rings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if let lastUpdate = activityMonitor.lastUpdateTime {
                    Text("Updated \(lastUpdate.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let activity = activityMonitor.currentActivity {
                ActivityRingsView(activity: activity)
            } else {
                PlaceholderRingsView()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Daily Metrics Section
    
    private var dailyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Goals") {
                    showingGoalSettings = true
                }
                .font(.subheadline)
                .foregroundStyle(.blue)
            }
            
            if let activity = activityMonitor.currentActivity {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    MetricCard(
                        icon: "figure.walk",
                        iconColor: .blue,
                        title: "Steps",
                        value: activity.formattedSteps,
                        goal: "\(activity.stepGoal)",
                        progress: activity.stepProgress
                    )
                    
                    MetricCard(
                        icon: "location.fill",
                        iconColor: .green,
                        title: "Distance",
                        value: activity.formattedDistance,
                        goal: "Goal",
                        progress: min(activity.distance / 5000, 1.0) // 5km goal
                    )
                    
                    MetricCard(
                        icon: "flame.fill",
                        iconColor: .orange,
                        title: "Calories",
                        value: activity.formattedActiveEnergy,
                        goal: "\(Int(activity.activeEnergyGoal))",
                        progress: activity.activeEnergyProgress
                    )
                    
                    MetricCard(
                        icon: "clock.fill",
                        iconColor: .purple,
                        title: "Exercise",
                        value: "\(activity.exerciseMinutes) min",
                        goal: "\(activity.exerciseGoal) min",
                        progress: activity.exerciseProgress
                    )
                }
            } else {
                PlaceholderMetricsView()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Health Metrics Section
    
    private var healthMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Health Metrics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Details") {
                    showingHealthDetails = true
                }
                .font(.subheadline)
                .foregroundStyle(.blue)
            }
            
            if let healthMetrics = activityMonitor.healthMetrics {
                HealthMetricsGrid(metrics: healthMetrics)
            } else {
                PlaceholderHealthMetricsView()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Activity Insights Section
    
    private var activityInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Insights")
                .font(.title2)
                .fontWeight(.bold)
            
            if let activity = activityMonitor.currentActivity {
                ActivityLevelCard(activity: activity)
            } else {
                PlaceholderInsightsView()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionButton(
                    icon: "target",
                    title: "Set Goals",
                    color: .blue
                ) {
                    showingGoalSettings = true
                }
                
                QuickActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "View Trends",
                    color: .green
                ) {
                    // Navigate to trends view
                }
                
                QuickActionButton(
                    icon: "heart.fill",
                    title: "Health",
                    color: .red
                ) {
                    showingHealthDetails = true
                }
                
                QuickActionButton(
                    icon: "trophy.fill",
                    title: "Achievements",
                    color: .yellow
                ) {
                    // Navigate to achievements view
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Activity Rings View

struct ActivityRingsView: View {
    let activity: ActivitySummaryModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Activity rings visualization
            ZStack {
                // Stand ring (outer)
                Circle()
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: activity.standProgress)
                    .stroke(Color.cyan, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                // Exercise ring (middle)
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 8)
                    .frame(width: 96, height: 96)
                
                Circle()
                    .trim(from: 0, to: activity.exerciseProgress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(-90))
                
                // Active energy ring (inner)
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 8)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .trim(from: 0, to: activity.activeEnergyProgress)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RingLegendItem(
                    color: .red,
                    title: "Move",
                    value: "\(Int(activity.activeEnergy))",
                    goal: "\(Int(activity.activeEnergyGoal))"
                )
                
                RingLegendItem(
                    color: .green,
                    title: "Exercise",
                    value: "\(activity.exerciseMinutes)",
                    goal: "\(activity.exerciseGoal)"
                )
                
                RingLegendItem(
                    color: .cyan,
                    title: "Stand",
                    value: "\(activity.standHours)",
                    goal: "\(activity.standGoal)"
                )
            }
            
            Spacer()
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let goal: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                
                Spacer()
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("of \(goal)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: iconColor))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct HealthMetricsGrid: View {
    let metrics: HealthMetricsModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            if metrics.hasHeartRateData {
                HealthMetricCard(
                    icon: "heart.fill",
                    iconColor: metrics.heartRateCategory.color,
                    title: "Heart Rate",
                    value: metrics.formattedHeartRate,
                    unit: "BPM"
                )
            }
            
            if let hrv = metrics.heartRateVariability {
                HealthMetricCard(
                    icon: "waveform.path.ecg",
                    iconColor: .blue,
                    title: "HRV",
                    value: metrics.formattedHeartRateVariability,
                    unit: "ms"
                )
            }
            
            if let spo2 = metrics.oxygenSaturation {
                HealthMetricCard(
                    icon: "lungs.fill",
                    iconColor: .cyan,
                    title: "Blood Oxygen",
                    value: metrics.formattedOxygenSaturation,
                    unit: "%"
                )
            }
            
            if let temp = metrics.bodyTemperature {
                HealthMetricCard(
                    icon: "thermometer",
                    iconColor: .orange,
                    title: "Temperature",
                    value: metrics.formattedBodyTemperature,
                    unit: "°C"
                )
            }
        }
    }
}

struct HealthMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ActivityLevelCard: View {
    let activity: ActivitySummaryModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: activity.activityLevel.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(activity.activityLevel.color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(activity.activityLevel.color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.activityLevel.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(activity.motivationalMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RingLegendItem: View {
    let color: Color
    let title: String
    let value: String
    let goal: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(value)/\(goal)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Placeholder Views

struct PlaceholderRingsView: View {
    var body: some View {
        HStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Loading activity data...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PlaceholderMetricsView: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 80)
            }
        }
    }
}

struct PlaceholderHealthMetricsView: View {
    var body: some View {
        Text("Health metrics will appear here when available")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct PlaceholderInsightsView: View {
    var body: some View {
        Text("Activity insights will appear here")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding()
    }
}

// MARK: - Preview

#Preview {
    ActivityDashboardView()
        .environment(ActivityMonitor.shared)
}