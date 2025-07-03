/*
Abstract:
Simple distance tracking view that shows only daily distance without requiring workout sessions.
*/

import SwiftUI

struct ActivityDashboardView: View {
    @Environment(StepTracker.self) private var stepTracker
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Distance Display
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
                
                Spacer()
            }
            .padding()
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
                }
            }
            .refreshable {
                stepTracker.refresh()
            }
        }
}

#Preview {
    ActivityDashboardView()
        .environment(StepTracker.shared)
}