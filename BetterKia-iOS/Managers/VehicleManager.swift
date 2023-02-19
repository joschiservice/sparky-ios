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

public class VehicleManager : ObservableObject {
    @Published var showClimateControlPopover = false;
    @Published var isLoadingVehicleData = false;
    @Published var vehicleData: VehicleStatus? = nil;
    @Published var currentHvacTargetTemp: Int? = nil;
    @Published var vehicleLocation: VehicleLocation? = nil;
    @Published var isLoadingVehicleLocation = false;
    @Published var isHvacActive = false;
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VehicleManager")
    
    public static var shared = VehicleManager()
    
    public func start() async {
        logger.log("Starting vehicle...");
        
        DispatchQueue.main.async {
            //self.showClimateControlPopover = true;
        }
        
        let result = await ApiClient.startVehicle();
        
        logger.log("Start: \(result?.message ?? "Unknown Error")");
        
        DispatchQueue.main.async {
            self.isHvacActive = true;
        }
    }
    
    public func stop() async {
        logger.log("Stopping vehicle...");
        
        let result = await ApiClient.stopVehicle();
        
        logger.log("Stop: \(result?.message ?? "Unknown Error")");
        
        if (result != nil) {
            if (result!.message == "SUCCESS") {
                DispatchQueue.main.async {
                    self.isHvacActive = false;
                }
            } else if (result!.message == "VEHICLE_RESPONSE_PENDING") {
                // Get vehicle data with refresh
            } else {
                // Unknown error
            }
        } else {
            let alertTitle = "HVAC: Stop error";
            let alertDescription = "An unknown error occured while stopping the hvac. It might be that the hvac is still active or it might stop soon.";
            AlertManager.shared.publishAlert(alertTitle, description: alertDescription);
        }
    }
    
    public func getVehicleData() async {
        DispatchQueue.main.async {
            self.isLoadingVehicleData = true;
        }
        
        logger.log("Retrieving vehicle status data...");
        let data = await ApiClient.getVehicleStatus();
        
        DispatchQueue.main.async {
            self.vehicleData = data;
            self.isHvacActive = data?.acc ?? false;
            self.isLoadingVehicleData = false;
        }
    }
    
    public func getVehicleLocation() async {
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
            evStatus: EvStatus(batteryCharge: true, batteryStatus: 20, drvDistance: [DriveDistance(rangeByFuel: RangeByFuel(totalAvailableRange: RangeData(value: 320, unit: 1)))]),
            time: "2022-03-01", acc: true, sideBackWindowHeat: 1, steerWheelHeat: 1, defrost: true)
        vmanager.vehicleLocation = VehicleLocation(latitude: 54.19478906001295, longitude: 9.093066782003024, speed: VehicleSpeed(unit: 0, value: 0), heading: 0);
        vmanager.isHvacActive = true;
        return vmanager;
    }
}
