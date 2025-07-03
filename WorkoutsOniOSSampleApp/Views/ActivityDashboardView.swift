/*
Abstract:
Simple distance tracking view that shows only daily distance without requiring workout sessions.
Following Apple's Liquid Glass design principles.
*/

import SwiftUI

struct ActivityDashboardView: View {
    @Environment(StepTracker.self) private var stepTracker
    
    var body: some View {
        NavigationView {
            ZStack {
                // Liquid glass background
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Distance Display Card with liquid glass effect
                    VStack(spacing: 16) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(.green)
                        
                        Text("Today's Distance")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        if let summary = stepTracker.dailySummary {
                            Text(summary.formattedDistance)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        } else {
                            Text("--")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .glassCard()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Distance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        stepTracker.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
            }
            .refreshable {
                stepTracker.refresh()
            }
        }
    }
}

#Preview {
    ActivityDashboardView()
        .environment(StepTracker.shared)
}