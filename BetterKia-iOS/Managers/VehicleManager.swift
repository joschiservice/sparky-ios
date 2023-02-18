//
//  VehicleManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 12.02.23.
//

import Foundation
import Dispatch
import os

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
    
    public func start() async -> Bool {
        logger.log("Starting vehicle...");
        
        DispatchQueue.main.async {
            //self.showClimateControlPopover = true;
        }
        
        let result = await ApiClient.startVehicle();
        
        logger.log("Start: \(result ? "Successful" : "Failed")");
        
        DispatchQueue.main.async {
            self.isHvacActive = true;
        }
        
        return result;
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
}
