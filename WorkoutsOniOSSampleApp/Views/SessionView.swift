/*
Abstract:
A SwiftUI view that shows the workout metric and controls as a single view.
*/

import SwiftUI

struct SessionView: View {
    @Environment(WorkoutManager.self) var workoutManager

    var body: some View {
        VStack {
            Image(systemName: "\(workoutManager.workoutConfiguration?.symbol ?? "figure.walk").circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.accent)
            MetricsView()
                .padding(.vertical)
            ControlsView()
        }
        .liquidGlassBackground()
    }
}

#Preview {
    NavigationView {
        SessionView()
            .environment(WorkoutManager())
    }
}
