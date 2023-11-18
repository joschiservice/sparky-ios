//
//  VehicleStatus.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

import Foundation

public struct VehicleStatus : Codable {
    let engine: Bool
    let evStatus: EvStatus
    let time: Date
    let acc: Bool // What is this value for?
    let sideBackWindowHeat: Int
    let steerWheelHeat: Int
    let defrost: Bool
    let airCtrlOn: Bool // True, when HVAC is active
    let doorLock: Bool
}
