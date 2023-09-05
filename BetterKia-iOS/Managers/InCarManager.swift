//
//  InCarManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 01.09.23.
//

import Foundation
import SwiftUI

/**
 Contains data related to features which can be accessed when the user is inside the car.
 Data in this class is provided by the main ECU, which is connected to the phone via Bluetooth.
 */
public class InCarManager: ObservableObject {
    public static var shared = InCarManager()
    
    // Connection Data
    @Published var isConnected = false;
    @Published var isConnecting = false;
    
    // UI
    @Published var isInCarUiActive = true;
    
    // InCar-related data
    @Published var ambientLightColor: Color?
}
