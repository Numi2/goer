/*
Abstract:
Simple app delegate for distance tracking app.
*/

import Foundation
import UIKit

class GoerAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = GoerAppSceneDelegate.self
        return configuration
    }
}
