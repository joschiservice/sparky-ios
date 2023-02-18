//
//  VehicleStatusResponse.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.12.22.
//

import Foundation

public struct VehicleLocationResponse: Decodable {
    let error: Bool
    let message: VehicleLocation
}

public struct VehicleLocation : Decodable {
    let latitude: Double
    let longitude: Double
    let speed: VehicleSpeed
    let heading: Double
}

public struct VehicleSpeed: Decodable {
    let unit: Int
    let value: Int
}

public struct VehicleStatusResponse: Decodable {
    let vehicleStatus: VehicleStatus
}

public struct VehicleStatus : Decodable {
    let evStatus: EvStatus
    let time: String
    let acc: Bool
    let sideBackWindowHeat: Int
    let steerWheelHeat: Int
    let defrost: Bool
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

