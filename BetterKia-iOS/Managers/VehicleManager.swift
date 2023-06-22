//
//  VehicleManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 12.02.23.
//

import Foundation
import Dispatch
import os
import SwiftUI
import MapKit

enum VehicleDataStatus {
    case Refreshing;
    case UnknownError;
    case Success;
    case RateLimitedByOEM;
}

struct CarPosition: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct Vehicle {
    let model: String;
    let vin: String;
}

public class VehicleManager : ObservableObject {
    @Published var showClimateControlPopover = false;
    @Published var isLoadingVehicleData = false;
    @Published var vehicleData: VehicleStatus? = nil;
    @Published var currentHvacTargetTemp: Int? = 21;
    @Published var vehicleLocation: VehicleLocation? = nil;
    @Published var isLoadingVehicleLocation = false;
    @Published var isHvacActive = false;
    @Published var vehicleDataStatus = VehicleDataStatus.Refreshing;
    @Published var isVehicleLocked = true;
    @Published var vehicleRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002));
    var lastVehicleDataUpdate: Date? = nil;
    @Published var vehiclePositionAnnotations: [CarPosition] = [];
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VehicleManager")
    
    public static var shared = VehicleManager()
    
    @Published public var primaryVehicle: PrimaryVehicleInfo? = nil;
    
    public func start() async {
        logger.log("Starting vehicle...");
        
        DispatchQueue.main.async {
            //self.showClimateControlPopover = true;
        }
        
        let result = await ApiClient.startVehicle();
        
        logger.log("Start: \(result?.code ?? "Unknown Error")");
        
        if (result == nil || result?.code != "SUCCESS") {
            logger.warning("StartVehicle: Received bad response. Checking vehicle status with a manual refresh...");
            
            AlertManager.shared.publishAlert("Error: Start air conditioning", description: "We were not able to ensure that the air conditioning has been started as the KiaConnect service wasn't able to retrieve data from the car in time.")
            return;
        }
        
        DispatchQueue.main.async {
            self.isHvacActive = true;
        }
    }
    
    public func getPrimaryVehicle(force: Bool = false) async -> PrimaryVehicleInfo? {
        if primaryVehicle != nil && !force {
            return primaryVehicle;
        }
        
        if IS_DEMO_MODE {
            return PrimaryVehicleInfo(vin: "EXAMPLE_VIN", modelName: "EXAMPLE_MODEL");
        }
        
        let data = await ApiClient.getPrimaryVehicle();
        
        DispatchQueue.main.async {
            self.primaryVehicle = data;
        }
        
        return primaryVehicle;
    }
    
    public func getVehicles() async -> [VehicleIdentification]? {
        if IS_DEMO_MODE {
            return [
                VehicleIdentification(vin: "EXAMPLE_VIN_1", nickname: "NICKNAME_1", modelName: "MODEL_1"),
                VehicleIdentification(vin: "EXAMPLE_VIN_2", nickname: "NICKNAME_2", modelName: "MODEL_2")
            ]
        }
        
        return await ApiClient.getVehicles();
    }
    
    public func stop() async {
        logger.log("Stopping vehicle...");
        
        let result = await ApiClient.stopVehicle();
        
        logger.log("Stop: \(result?.code ?? "Unknown Error")");
        
        if (result == nil || result?.code != "SUCCESS") {
            AlertManager.shared.publishAlert("Stop air conditioning", description: "We were not able to ensure that the air conditioning has been stopped as the KiaConnect service wasn't able to retrieve data from the car in time.")
            return;
        }
        
        DispatchQueue.main.async {
            self.isHvacActive = false;
        }
    }
    
    public func getVehicleData(forceRefresh: Bool = false) async {
        DispatchQueue.main.async {
            self.isLoadingVehicleData = true;
            self.vehicleDataStatus = VehicleDataStatus.Refreshing;
        }
        
        logger.log("Retrieving vehicle status data...");
        let response = await ApiClient.getVehicleStatus(refreshData: forceRefresh);
        
        DispatchQueue.main.async {
            if (response.failed) {
                if (response.error == ApiErrorType.RateLimitedByOEM) {
                    self.vehicleDataStatus = VehicleDataStatus.RateLimitedByOEM;
                } else if (response.error == ApiErrorType.InvalidBrandSession) {
                    self.vehicleDataStatus = VehicleDataStatus.UnknownError;
                    AlertManager.shared.publishAlert("Reconnect your Kia account", description: "The connection with the KiaConnect service has expired. Please reconnect your Kia account in the settings to continue using Sparky.")
                } else {
                    self.vehicleDataStatus = VehicleDataStatus.UnknownError;
                }
            } else {
                self.vehicleDataStatus = VehicleDataStatus.Success;
            }
            
            self.lastVehicleDataUpdate = Date();
            self.vehicleData = response.data;
            self.isHvacActive = response.data?.airCtrlOn ?? false;
            self.isVehicleLocked = response.data?.doorLock ?? false;
            self.isLoadingVehicleData = false;
        }
    }
    
    public func getVehicleLocation() async {
        // DEMO
        DispatchQueue.main.async {
            self.logger.log("Location: setting demo data");
            self.vehicleLocation = VehicleLocation(latitude: 53.546925, longitude: 9.998855, speed:VehicleSpeed(unit: 1, value: 0), heading: 0)
            
            let mapLocation = CLLocationCoordinate2D(latitude: self.vehicleLocation!.latitude, longitude: self.vehicleLocation!.longitude)
            
            self.vehicleRegion = MKCoordinateRegion(center: mapLocation, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
            
            self.vehiclePositionAnnotations.append(CarPosition(name: "Car", coordinate: self.vehicleRegion.center));
            
            self.isLoadingVehicleLocation = false;
        }
        return;
        DispatchQueue.main.async {
            self.isLoadingVehicleLocation = true;
        }
        
        logger.log("Retrieving vehicle location...");
        let data = await ApiClient.getVehicleLocation();
        
        DispatchQueue.main.async {
            self.logger.log("Location: request finished");
            if (data != nil && !data!.error) {
                self.vehicleLocation = data?.message;
            } else {
                self.logger.log("Location: no data avilable");
                self.vehicleLocation = nil;
            }
            self.isLoadingVehicleLocation = false;
        }
    }
    
    public func getCurrentTemperature(startTemp: Double, targetTemp: Double, startTime: Date) -> Double {
        let timeToHeatUp = 15.0 // in minutes
        let timeElapsed = min(timeToHeatUp, (Date().timeIntervalSince1970 - startTime.timeIntervalSince1970) / 60) // in minutes
        
        // Using a sigmoid function as a curve
        func curve(x: Double) -> Double {
            let k = 0.1 // A constant to adjust the steepness of the curve
            return targetTemp / (1 + exp(-k * (x - timeToHeatUp / 2)))
        }
        
        let currentTemp = curve(x: timeElapsed) + startTemp
        return currentTemp
    }
    
    /**
     Returns an instance of VehicleManager, that is optimized for usage in preview environments.
     */
    public static func getPreviewInstance() -> VehicleManager {
        let vmanager = VehicleManager();
        vmanager.currentHvacTargetTemp = 22
        vmanager.vehicleData = VehicleStatus(
            engine: false, evStatus: EvStatus(batteryCharge: true, batteryStatus: 20, drvDistance: [DriveDistance(rangeByFuel: RangeByFuel(totalAvailableRange: RangeData(value: 320, unit: 1)))]),
            time: Date(), acc: true, sideBackWindowHeat: 1, steerWheelHeat: 1, defrost: true, airCtrlOn: false, doorLock: false)
        vmanager.vehicleLocation = VehicleLocation(latitude: 54.19478906001295, longitude: 9.093066782003024, speed: VehicleSpeed(unit: 0, value: 0), heading: 0);
        vmanager.isHvacActive = true;
        return vmanager;
    }
    
    public func lock() async {
        let result = await ApiClient.lockVehicle();
        
        if (result == nil || result?.code != "SUCCESS") {
            logger.warning("LockVehicle: Received bad response. Checking vehicle status with a manual refresh...");
            
            AlertManager.shared.publishAlert("Error: Start air conditioning", description: "We were not able to ensure that the air conditioning has been started as the KiaConnect service wasn't able to retrieve data from the car in time.")
            
            return;
        }
        
        DispatchQueue.main.async {
            self.isVehicleLocked = true;
        }
    }
    
    public func unlock() async {
        let result = await ApiClient.unlockVehicle();
        
        if (result == nil || result?.code != "SUCCESS") {
            logger.warning("UnlockVehicle: Received bad response. Checking vehicle status with a manual refresh...");
            
            AlertManager.shared.publishAlert("Error: Unlock vehicle", description: "We were not able to ensure that the vehicle has been unlocked as the KiaConnect service wasn't able to retrieve data from the car in time.")
            
            return;
        }
        
        DispatchQueue.main.async {
            self.isVehicleLocked = false;
        }
    }
}
