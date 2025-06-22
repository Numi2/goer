/*
Abstract:
A SwiftUI view that shows the workout controls.
*/

import SwiftUI

struct ControlsView: View {
    @Environment(WorkoutManager.self) var workoutManager
    
    var body: some View {
        HStack {
            VStack {
                    Button {
                        withAnimation {
                            workoutManager.endWorkout()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .font(.largeTitle)
                    }
                    .padding(.leading)
                    .buttonStyle(.bordered)
                    .tint(.red)
            }
            
            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.state == .running ? "pause.fill" : "arrow.clockwise")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .font(.largeTitle)
                }
                .padding(.trailing)
                .buttonStyle(.bordered)
                .tint(.yellow)
            }
        }
    }
}

#Preview {
    ControlsView()
        .environment(WorkoutManager())
}
