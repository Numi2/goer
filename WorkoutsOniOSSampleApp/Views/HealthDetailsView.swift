/*
Abstract:
Health details view showing comprehensive health metrics and trends.
*/

import SwiftUI

struct HealthDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ActivityMonitor.self) private var activityMonitor
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Current Health Status
                    currentHealthSection
                    
                    // Vital Signs
                    vitalSignsSection
                    
                    // Health Trends (placeholder)
                    healthTrendsSection
                }
                .padding()
            }
            .navigationTitle("Health Metrics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Current Health Section
    
    private var currentHealthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Status")
                .font(.title2)
                .fontWeight(.bold)
            
            if let healthMetrics = activityMonitor.healthMetrics {
                VStack(spacing: 12) {
                    if healthMetrics.hasHeartRateData {
                        HealthDetailCard(
                            icon: "heart.fill",
                            iconColor: healthMetrics.heartRateCategory.color,
                            title: "Heart Rate",
                            value: healthMetrics.formattedHeartRate,
                            unit: "BPM",
                            status: healthMetrics.heartRateCategory.rawValue,
                            lastUpdated: healthMetrics.date
                        )
                    }
                    
                    if let hrv = healthMetrics.heartRateVariability {
                        HealthDetailCard(
                            icon: "waveform.path.ecg",
                            iconColor: .blue,
                            title: "Heart Rate Variability",
                            value: healthMetrics.formattedHeartRateVariability,
                            unit: "ms",
                            status: "Normal",
                            lastUpdated: healthMetrics.date
                        )
                    }
                }
            } else {
                NoHealthDataView()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Vital Signs Section
    
    private var vitalSignsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vital Signs")
                .font(.title2)
                .fontWeight(.bold)
            
            if let healthMetrics = activityMonitor.healthMetrics {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    if let spo2 = healthMetrics.oxygenSaturation {
                        VitalSignCard(
                            icon: "lungs.fill",
                            iconColor: .cyan,
                            title: "Blood Oxygen",
                            value: healthMetrics.formattedOxygenSaturation,
                            unit: "%",
                            normalRange: "95-100%"
                        )
                    }
                    
                    if let temp = healthMetrics.bodyTemperature {
                        VitalSignCard(
                            icon: "thermometer",
                            iconColor: .orange,
                            title: "Body Temperature",
                            value: healthMetrics.formattedBodyTemperature,
                            unit: "°C",
                            normalRange: "36.1-37.2°C"
                        )
                    }
                    
                    if let systolic = healthMetrics.bloodPressureSystolic,
                       let diastolic = healthMetrics.bloodPressureDiastolic {
                        VitalSignCard(
                            icon: "heart.circle",
                            iconColor: .red,
                            title: "Blood Pressure",
                            value: "\(Int(systolic))/\(Int(diastolic))",
                            unit: "mmHg",
                            normalRange: "<120/80"
                        )
                    }
                }
            } else {
                NoVitalSignsView()
            }
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
            
            Text("Historical health trends will be available here. Connect more health devices to see comprehensive analytics.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            
            // Placeholder for future trend charts
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 120)
                .overlay {
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        
                        Text("Trends Coming Soon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Supporting Views

struct HealthDetailCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    let status: String
    let lastUpdated: Date
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text(status)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(iconColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(iconColor)
                    
                    Spacer()
                    
                    Text("Updated \(lastUpdated.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct VitalSignCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    let normalRange: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconColor)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text("Normal: \(normalRange)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct NoHealthDataView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Health Data Available")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Connect health devices or allow access to HealthKit to see your health metrics here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct NoVitalSignsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Vital Signs Data")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Vital signs will appear here when available from connected health devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    HealthDetailsView()
        .environment(ActivityMonitor.shared)
}