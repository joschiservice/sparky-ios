//
//  AppDelegate.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 18.12.22.
//

import Foundation
import UIKit
import os

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Record the device token.
    }
}
