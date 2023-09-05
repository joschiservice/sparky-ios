//
//  BluetoothDelegate.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 01.09.23.
//

import Foundation
import CoreBluetooth
import os

class BluetoothDelegate : NSObject, CBCentralManagerDelegate {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BluetoothDelegate")
    
    public var centralManager: CBCentralManager!
    
    public var mainEcuPeripheral: CBPeripheral?
    private var mainEcuDelegate: MainEcuDelegate?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if centralManager.state == CBManagerState.poweredOn {
            logger.info("Scanning for peripherals");
            centralManager.scanForPeripherals(withServices: [MainEcuDelegate.NG_1_MAIN_SERVICE_ID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            logger.error("Unexpected central manager state: \(self.centralManager.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        logger.info("Discovered new device: \(String(describing: peripheral.name))")
        
        if mainEcuPeripheral != peripheral {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
            mainEcuPeripheral = peripheral
            
            logger.info("Connecting to perhiperal \(peripheral)")
            InCarManager.shared.isConnecting = true;
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Connected to device: \(String(describing: peripheral.name))")
        mainEcuDelegate = MainEcuDelegate(peripheral: peripheral)
        peripheral.delegate = mainEcuDelegate
        peripheral.discoverServices(MainEcuDelegate.SERVICES)
        InCarManager.shared.isConnecting = false
    }
}
