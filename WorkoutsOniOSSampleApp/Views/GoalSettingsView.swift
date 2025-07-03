/*
Abstract:
Goal settings view for configuring daily activity targets.
*/

import SwiftUI

struct GoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stepGoal = 10000
    @State private var activeEnergyGoal = 400.0
    @State private var exerciseGoal = 30
    @State private var standGoal = 12
    
    var body: some View {
        NavigationView {
            Form {
                Section("Daily Activity Goals") {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Steps")
                            Text("\(stepGoal) steps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Stepper("", value: $stepGoal, in: 1000...50000, step: 500)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Active Energy")
                            Text("\(Int(activeEnergyGoal)) cal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Stepper("", value: $activeEnergyGoal, in: 50...1000, step: 25)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.green)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Exercise")
                            Text("\(exerciseGoal) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Stepper("", value: $exerciseGoal, in: 5...120, step: 5)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Image(systemName: "figure.stand")
                            .foregroundStyle(.cyan)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Stand Hours")
                            Text("\(standGoal) hours")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Stepper("", value: $standGoal, in: 6...16, step: 1)
                            .labelsHidden()
                    }
                }
                
                Section("Recommendations") {
                    Text("Goals are based on your activity level and health profile. Adjust them to match your personal fitness objectives.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save goals to ActivityMonitor
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    GoalSettingsView()
}