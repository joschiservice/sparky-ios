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
}
