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
    
    var body: some View {
        TabView {
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("History")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }
        }
    }
}

// Placeholder views for the tabs
struct HistoryView: View {
    var body: some View {
        VStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Workout History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your completed workouts will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("History")
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("Health") {
                Label("HealthKit", systemImage: "heart")
                Label("Permissions", systemImage: "lock.shield")
            }
            
            Section("Notifications") {
                Label("Workout Reminders", systemImage: "bell")
                Label("Achievement Alerts", systemImage: "star")
            }
            
            Section("About") {
                Label("Version", systemImage: "info.circle")
                Label("Privacy Policy", systemImage: "hand.raised")
            }
        }
        .navigationTitle("Settings")
    }
}

