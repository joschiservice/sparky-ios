//
//  AppDelegate.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 18.12.22.
//

import Foundation
import UIKit
import os
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication,
               didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       // Override point for customization after application launch.you’re
       UIApplication.shared.registerForRemoteNotifications()
       return true
    }

    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
       // ToDo: send deviceToken to server
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        Logger().log("Device token: \(token)")
    }

    func application(_ application: UIApplication,
                didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
       // Try again later.
    }
}
