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
import ActivityKit
import Sentry
import CoreBluetooth
import ExternalAccessory
import CoreLocation
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate, CBPeripheralDelegate {
    public let bleDelegate: BluetoothDelegate = BluetoothDelegate()
    
    lazy var coreDataStack: CoreDataStack = .init(modelName: "Main")
    
    /**
     Called when starting the app
     */
    func application(_ application: UIApplication,
               didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup Sentry. This should always be first to capture errors and report them
        SentrySDK.start { options in
            options.dsn = "https://dbf25dbe96e24b2c886de65a8b6a9b81@o1249248.ingest.sentry.io/4504706464022528"
            options.tracesSampleRate = 1.0
        }
        
        // Setup Authentication service
        AuthManager.shared.initialize();
        
        // Setup Notifications
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Logger().error("An error occured while requesting notification permissions: \(error)")
            }
        }
        
        // When the app launch after user tap on notification (originally was not running / not in background)
        if (launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
            print("Hi there! I was opened using a notification I guess")
        }
        
        // Bluetooth
        bleDelegate.centralManager = CBCentralManager(delegate: bleDelegate, queue: nil)
        
        return true
    }

    /**
     Called when device is registered for remote notifications
     */
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken: Data) {
        let token = deviceToken.map{ String(format: "%.2hhx", $0) }.joined()
        
        Task {
            _ = await ApiClient.registerDeviceToken(deviceToken: token)
        }
        
        let liveChargingStartCategory = UNNotificationCategory(identifier: "LIVE_CHARGING",
                                                               actions: [],
                                                               intentIdentifiers: [],
                                                               hiddenPreviewsBodyPlaceholder: "",
                                                               options: .customDismissAction)
        
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([liveChargingStartCategory])

    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        Logger().log("Error: failed")
    }
    
    
    var liveChargingActivity: Activity<LiveChargeStatusWidgetAttributes>?
    
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show the notification alert (banner), and with sound
        completionHandler([.banner, .list, .sound])
    }
    
    struct UserInfoData {
        let chargeStatus: InitialChargeStatus
    }
    
    struct InitialChargeStatus {
        let batteryCharge: Int
        let chargeLimit: Int
        let chargedKw: Int
        let minRemaining: Int
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger().log("User clicked on notificaiton")
        
        if response.notification.request.content.categoryIdentifier == "LIVE_CHARGING" {
            let userInfo = response.notification.request.content.userInfo["chargeStatus"] as! NSDictionary
            let batteryCharge = userInfo["batteryCharge"] as! Int
            let minRemaining = userInfo["minRemaining"] as! Int
            let chargeLimit = userInfo["chargeLimit"] as! Int
            let chargedKw = userInfo["chargedKw"] as! Int
            
            Logger().log("Starting live charging monitoring...")
            
            if ActivityAuthorizationInfo().areActivitiesEnabled {
                let initialContentState = LiveChargeStatusWidgetAttributes.ContentState(batteryCharge: batteryCharge, minRemaining: minRemaining, chargeLimit: chargeLimit, chargedKw: chargedKw)
                let activityAttributes = LiveChargeStatusWidgetAttributes()
                
                let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)
                
                do {
                    self.liveChargingActivity = try Activity.request(attributes: activityAttributes, content: activityContent, pushType: .token)
                    
                    Task {
                        for try await element in liveChargingActivity!.pushTokenUpdates {
                            let token = element.map { String(format: "%.2hhx", $0) }.joined()
                            _ = await ApiClient.registerForLiveChargingUpdates(liveActivitydeviceToken: token)
                        }
                    }

                    } catch (let error) {
                        print("Error requesting Charging Live Activity \(error.localizedDescription).")
                    }
            }
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
          let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
          sceneConfig.delegateClass = SceneDelegate.self
          return sceneConfig
      }
}
