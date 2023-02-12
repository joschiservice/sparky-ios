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

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
               didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       // Override point for customization after application launch.you’re
       UIApplication.shared.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                Logger().error("An error occured while requesting notification permissions: \(error)")
            }
            
            // Enable or disable features based on the authorization.
        }
        
        // When the app launch after user tap on notification (originally was not running / not in background)
          if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
              print("Hi there! I was opened using a notification I guess")
          }
        
        
       return true
    }

    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken: Data) {
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        Logger().log("Device token: \(token)")
        
        Task {
            _ = await ApiClient.registerDeviceToken(deviceToken: token)
        }
        
        let liveChargingStartCategory =
              UNNotificationCategory(identifier: "LIVE_CHARGING",
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
    
    
    var deliveryActivity: Activity<LiveChargeStatusWidgetAttributes>?
    
    // This function will be called when the app receive notification
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        Logger().log("User clicked on notificaiton")
        // Do whatever you want when the user tapped on a notification
        // If you are waiting for specific data from the notification
        // (e.g., key: "target" and associated with "v alue"),
        // you can capture it as follows then do the navigation:

        // You may print `userInfo` dictionary, to see all data received with the notification.
        if response.notification.request.content.categoryIdentifier == "LIVE_CHARGING"
        {
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
                    self.deliveryActivity = try Activity.request(attributes: activityAttributes, content: activityContent, pushType: .token)
                    
                    Task {
                        for try await element in deliveryActivity!.pushTokenUpdates {
                            let token = element.map { String(format: "%.2hhx", $0) }.joined()
                            _ = await ApiClient.registerForLiveChargingUpdates(liveActivitydeviceToken: token)
                        }
                    }

                    } catch (let error) {
                        print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
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
