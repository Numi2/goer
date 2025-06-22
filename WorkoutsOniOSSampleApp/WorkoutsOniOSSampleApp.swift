/*
Abstract:
Clean SwiftUI workout app following Apple's Liquid Glass design principles.
*/

import SwiftUI

@main
struct GoerApp: App {
    @UIApplicationDelegateAdaptor(GoerAppDelegate.self) var appDelegate
    @State private var workoutManager = WorkoutManager.shared
    @State private var navigationModel = NavigationModel()
    
    init() {
        navigationModel.observeWorkoutManager(workoutManager: workoutManager)
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutManager)
                .environment(navigationModel)
        }
    }
}

struct ContentView: View {
    @Environment(NavigationModel.self) var navigationModel
    @Environment(WorkoutManager.self) var workoutManager
    
    var body: some View {
        Group {
            switch navigationModel.viewState {
            case .startView:
                MainTabView()
            case .countdownView:
                CountDownView()
                    .transition(.move(edge: .bottom))
            case .sessionView:
                SessionView()
                    .transition(.move(edge: .trailing))
            case .summaryView:
                NavigationStack {
                    SummaryView()
                }
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationModel.viewState)
    }
}

struct MainTabView: View {
    @Environment(WorkoutManager.self) var workoutManager
    
    var body: some View {
        TabView {
            NavigationStack {
                StartView()
            }
            .tabItem {
                Image(systemName: "figure.run")
                Text("Workouts")
            }
            
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

