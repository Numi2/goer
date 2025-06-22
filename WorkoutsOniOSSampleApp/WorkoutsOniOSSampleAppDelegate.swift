/*
Abstract:
The UIKit app delegate of the app.
*/

import Foundation
import HealthKitUI
import UIKit
import Intents

class GoerAppDelegate: NSObject, UIApplicationDelegate {
    let handler = IntentHandler()
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if options.shouldHandleActiveWorkoutRecovery {
            let store = HKHealthStore()
            store.recoverActiveWorkoutSession(completion: { (workoutSession, error) in
                if let error = error {
                    print("Failed to recoverActiveWorkoutSession due to: \(error)")
                } else if let workoutSession = workoutSession {
                    Task {
                        await WorkoutManager.shared.recoverWorkout(recoveredSession: workoutSession)
                    }
                }
            })
        }
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = GoerAppSceneDelegate.self
        return configuration
    }
    
    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        return handler
    }
}
