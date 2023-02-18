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
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VehicleManager")
    
    public static var shared = VehicleManager()
    
    public func start() async -> Bool {
        logger.log("Starting vehicle...");
        
        DispatchQueue.main.async {
            self.showClimateControlPopover = true;
        }
        
        let result = await ApiClient.startVehicle();
        
        logger.log("Start: \(result ? "Successful" : "Failed")");
        
        return result;
    }
    
    public func getCurrentTemperature(startTemp: Double, targetTemp: Double, startTime: Date) -> Double {
        let timeToHeatUp = 15.0 // in minutes
        let timeElapsed = min(timeToHeatUp, (Date().timeIntervalSince1970 - startTime.timeIntervalSince1970) / 60) // in minutes
        let temperatureIncrease = (targetTemp - startTemp) / timeToHeatUp
        
        // Using a sigmoid function as a curve
        func curve(x: Double) -> Double {
            let k = 0.1 // A constant to adjust the steepness of the curve
            return targetTemp / (1 + exp(-k * (x - timeToHeatUp / 2)))
        }
        
        let currentTemp = curve(x: timeElapsed) + startTemp
        return currentTemp
    }
}
