//
//  VehicleStatusResponse.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.12.22.
//

import Foundation

public struct VehicleStatusResponse: Decodable {
    let vehicleStatus: VehicleStatus
}

public struct VehicleStatus : Decodable {
    let evStatus: EvStatus
    let time: String
}

public struct EvStatus: Decodable {
    let batteryCharge: Bool
    let batteryStatus: Int
    let drvDistance : [DriveDistance]
}

public struct DriveDistance: Decodable {
    let rangeByFuel: RangeByFuel
}

public struct RangeByFuel: Decodable {
    let totalAvailableRange: RangeData
}

public struct RangeData: Decodable {
    let value: Int
    let unit: Int
}

