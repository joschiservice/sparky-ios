//
//  MainEcuDelegate.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 01.09.23.
//

import Foundation
import CoreBluetooth
import os
import SwiftUI

/**
 Delegate for communication with the the main ECU peripheral.
 */
class MainEcuDelegate: NSObject, CBPeripheralDelegate {
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MainEcuDelegate")
    
    private static let CURRENT_COLOR_CHARACTERISTIC_ID = CBUUID(string: "fe430623-58ee-4ea9-8b1e-b6e57904048c")
    public static let NG_1_MAIN_SERVICE_ID = CBUUID(string: "a317a887-d070-48dc-a917-6f812a434fe1")
    public static let SERVICES = [NG_1_MAIN_SERVICE_ID]
    private let CHARACTERISTICS = [CURRENT_COLOR_CHARACTERISTIC_ID]
    
    public var peripheral: CBPeripheral
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            logger.error("Error on call for didUpdateValueFor: \(error)")
            return
        }
        
        if characteristic.value == nil {
            logger.error("Skipped characteristic parsing because value is nil")
            return
        }
        
        switch characteristic.uuid {
        case MainEcuDelegate.CURRENT_COLOR_CHARACTERISTIC_ID:
            // Data Parsing
            var stringData = String(data: characteristic.value!, encoding: .utf8)
            var dataArray = stringData?.components(separatedBy: ";") // R;G;B;A
            if dataArray == nil {
                logger.error("Failed to parse current color data")
                break
            }
            
            // Value conversion
            var red = Double(dataArray![0])! / 255
            var green = Double(dataArray![1])! / 255
            var blue = Double(dataArray![2])! / 255
            var opacity = Double(dataArray![3])!
            
            logger.info("Color data: R:\(red) G: \(green) B: \(blue) A: \(opacity)")
            
            InCarManager.shared.ambientLightColor = Color(red: red, green: green, blue: blue, opacity: opacity)
            break
            
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else {
            // handle error
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(CHARACTERISTICS, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        let colorCharacteristic = service.characteristics!.first {
            $0.uuid == MainEcuDelegate.CURRENT_COLOR_CHARACTERISTIC_ID
        }
        
        if colorCharacteristic == nil {
            logger.error("Color characteristic not available")
            return
        }
        
        peripheral.readValue(for: colorCharacteristic!)
    }
}
