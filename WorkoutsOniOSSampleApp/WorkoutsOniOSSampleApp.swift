/*
Abstract:
Clean SwiftUI workout app following Apple's Liquid Glass design principles.
*/

import SwiftUI

@main
struct GoerApp: App {
    @UIApplicationDelegateAdaptor(GoerAppDelegate.self) var appDelegate
    @State private var stepTracker = StepTracker.shared
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stepTracker)
        }
    }
}

struct ContentView: View {
    @Environment(StepTracker.self) var stepTracker
    
    var body: some View {
        MainTabView()
    }
}

struct MainTabView: View {
    @Environment(StepTracker.self) var stepTracker
    
    var body: some View {
        TabView {
            ActivityDashboardView()
                .tabItem {
                    Image(systemName: "location.fill")
                    Text("Distance")
                }
            
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("History")
            }
        }
    }
}

// Simple history view showing distance for each day
struct HistoryView: View {
    @Environment(StepTracker.self) private var stepTracker
    
    // Sample daily distance data - replace with real HealthKit data later
    let dailyDistances = [
        DailyDistance(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, distance: 4200),
        DailyDistance(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, distance: 3800),
        DailyDistance(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, distance: 5100),
        DailyDistance(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, distance: 2900),
        DailyDistance(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, distance: 6200),
        DailyDistance(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, distance: 4700),
        DailyDistance(date: Date(), distance: stepTracker.dailySummary?.distanceToday ?? 0)
    ]
    
    var body: some View {
        List {
            ForEach(dailyDistances.reversed(), id: \.date) { dayData in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dayData.date, style: .date)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text(dayData.date, format: .dateTime.weekday(.wide))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(dayData.formattedDistance)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Distance History")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DailyDistance {
    let date: Date
    let distance: Double // in meters
    
    var formattedDistance: String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
}