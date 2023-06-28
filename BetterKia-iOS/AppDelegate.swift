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

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    public var centralManager: CBCentralManager!
    var locationManager: CLLocationManager!
    
    lazy var coreDataStack: CoreDataStack = .init(modelName: "Main")
    
    func application(_ application: UIApplication,
               didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SentrySDK.start { options in
                options.dsn = "https://dbf25dbe96e24b2c886de65a8b6a9b81@o1249248.ingest.sentry.io/4504706464022528"

                // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
                // We recommend adjusting this value in production.
                options.tracesSampleRate = 1.0
            }
        
        
        
        // Setup Authentication service
        AuthManager.shared.initialize();
        
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
        
        if (UserDefaults.standard.bool(forKey: "BLE_AUTOLOCK_ACTIVATED")) {
            centralManager = CBCentralManager(delegate: self, queue: nil/*, options: [CBCentralManagerOptionRestoreIdentifierKey: "net.nextgendrive.sparky.centralManager"]*/)
            
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
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
    
    @objc func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Scan for BLE devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("Bluetooth is not available")
        }
    }
    
    var carPeripheral: CBPeripheral?

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Connect to the desired peripheral
        if peripheral.identifier == UUID(uuidString: "E2131BC2-A4CB-7A22-8346-9893C41B6F14") {
            let distance = calculateDistance(from: RSSI)
            // Do something with the distance value, such as call a function
            print("PERIPHERAL DISTANCE TO '\(peripheral.name ?? "n/a")' is \(String(format: "%.2f", distance))m")
            
            carPeripheral = peripheral;
            
            centralManager.connect(peripheral);
        }
    }
    
    var backgroundTimer: Timer?
    
    @objc func updateRSSI() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTime = formatter.string(from: date)
        
        print("\(currentTime): Updating RSSI...")
        if carPeripheral == nil {
            return;
        }
        
        carPeripheral?.readRSSI();
    }
    
    var task: BGTask?

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Discover the services and characteristics of the peripheral
        //peripheral.discoverServices([CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")])
        print("Peripheral \(peripheral.name ?? "n/a") is connected!")
        
        peripheral.delegate = self;
        
        carPeripheral = peripheral;
        
        updateRSSI()
        
        /*backgroundTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateRSSI), userInfo: nil, repeats: true)
        RunLoop.current.add(backgroundTimer!, forMode: .default)*/
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(error?.localizedDescription ?? "")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                // Discover the characteristics of each service
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Subscribe to the characteristic to receive updates
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            print("Got a value")
            // Parse the data from the BLE device
            /*let distance = // Parse the distance from the data
            if distance < 1.0 {
                // Call a function if the distance is less than 1 meter
                myFunction()
            }*/
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(peripheral.name) has been disconnected!");
    }
    
    var wasNearVehicle = false;
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        
        // Use the RSSI value to estimate the distance between the devices
        let distance = calculateDistance(from: RSSI)
        // Do something with the distance value, such as call a function
        print("CURRENT DISTANCE TO PERIPHERAL (CAR): \(String(format: "%.2f", distance))m (RSSI: \(RSSI))");
        
        if RSSI.intValue < -70 {
            print("in LOCK distance")
            
            if !wasNearVehicle {
                updateRSSI();
                return;
            }
            Task {
                let data = await ApiClient.getVehicleStatus();
                
                if !data.failed && data.data != nil && !data.data!.doorLock {
                    _ = await ApiClient.lockVehicle();
                }
                
                wasNearVehicle = false
            }
        } else {
            wasNearVehicle = true;
            print("Unlock distanc")
            // We could unlock here but idk how safe this might be
            updateRSSI();
        }
    }
    
    func calculateDistance(from RSSI: NSNumber) -> Double {
        let txPower = -59.0 // The RSSI at 1 meter distance
            let ratio = RSSI.doubleValue / txPower
            if ratio < 1.0 {
                return pow(ratio, 10)
            } else {
                let distance = (0.89976) * pow(ratio, 7.7095) + 0.111
                return distance
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got location update")
        // Get the most recent location
        let location = locations.last!
        // Do something with the location, such as update a label or call a function
        updateRSSI();
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("Restoring centrail manager")
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                print("store connect to peripheral \(peripheral.name)")
                if peripheral.identifier != UUID(uuidString: "E2131BC2-A4CB-7A22-8346-9893C41B6F14") {
                    return;
                }
                
                if peripheral.state == .connected {
                    carPeripheral = peripheral;
                    updateRSSI()
                } else {
                    // Re-connect to the previously connected peripherals
                    print("store is reconnecting to \(peripheral.name)")
                    centralManager.connect(peripheral, options: nil)
                }
            }
        }
    }
}
