/*
Abstract:
Advanced SwiftUI workout app with revolutionary liquid glass design and immersive user experience.
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
            GlassEffectContainer(spacing: 40) {
                ZStack {
                    // Dynamic background that adapts to current view
                    backgroundForCurrentView
                    
                    // Main content with sophisticated transitions
                    mainContent
                        .environment(workoutManager)
                        .advancedLiquidGlassAppStyle()
                }
            }
            .preferredColorScheme(.dark) // Liquid glass looks stunning in dark mode
        }
    }
    
    @ViewBuilder
    private var backgroundForCurrentView: some View {
        switch navigationModel.viewState {
        case .startView:
            DynamicMeshGradient(
                colors: [.blue, .purple, .indigo],
                animation: .easeInOut(duration: 10.0).repeatForever(autoreverses: true)
            )
        case .countdownView:
            DynamicMeshGradient(
                colors: [.orange, .red, .pink],
                animation: .easeInOut(duration: 3.0).repeatForever(autoreverses: true)
            )
        case .sessionView:
            DynamicMeshGradient(
                colors: [.green, .mint, .cyan],
                animation: .linear(duration: 15.0).repeatForever(autoreverses: false)
            )
        case .summaryView:
            DynamicMeshGradient(
                colors: [.purple, .blue, .cyan],
                animation: .easeInOut(duration: 8.0).repeatForever(autoreverses: true)
            )
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch navigationModel.viewState {
        case .startView:
            NavigationStack {
                StartView()
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .scale(scale: 1.1).combined(with: .opacity)
            ))
            
        case .countdownView:
            CountDownView()
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .move(edge: .bottom)),
                    removal: .scale(scale: 1.2).combined(with: .opacity)
                ))
            
        case .sessionView:
            SessionView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            
        case .summaryView:
            NavigationStack {
                SummaryView()
            }
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }
}

/// Dynamic mesh gradient background that creates immersive environments
private struct DynamicMeshGradient: View {
    let colors: [Color]
    let animation: Animation
    
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .overlay {
            // Additional depth layer
            RadialGradient(
                colors: [
                    Color.clear,
                    colors.first?.opacity(0.3) ?? Color.clear,
                    Color.clear
                ],
                center: animateGradient ? .topLeading : .bottomTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(animation) {
                animateGradient.toggle()
            }
        }
    }
}

