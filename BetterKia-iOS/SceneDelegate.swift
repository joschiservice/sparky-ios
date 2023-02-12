//
//  SceneDelegate.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 12.02.23.
//

import UIKit
import os

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
      
    }

    func sceneWillResignActive(_ scene: UIScene) {
      
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
      
    }
    
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QuickActions")
        
        logger.log("Executing quick action type: \(shortcutItem.type)")
        
        switch (shortcutItem.type) {
        case "StartHvacAction":
            logger.log("Requesting immediate start of hvac...")
            Task {
                completionHandler(await VehicleManager.shared.start())
            }
        default:
            completionHandler(false)
        }
    }
}
