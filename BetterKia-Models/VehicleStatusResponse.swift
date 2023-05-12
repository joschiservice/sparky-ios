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

enum ApiErrorType {
    case NoError
    case RateLimitedByOEM
    case UnknownError
    case InvalidBrandSession
}

public struct CommonResponse<T> {
    let failed: Bool
    let error: ApiErrorType
    let data: T?
}

public struct VehicleStatus : Decodable {
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

public struct VehicleIdentification: Decodable {
    let vin: String;
    
    let nickname: String;
    
    let modelName: String;
    
    enum CodingKeys: String, CodingKey {
        case vin
        case nickname
        case modelName = "name"
    }
}

public struct PrimaryVehicleInfo: Decodable {
    let vin: String;
    
    let modelName: String;
    
    enum CodingKeys: String, CodingKey {
        case vin
        case modelName = "model"
    }
}

public struct SetPrimaryVehicleData: Encodable {
    let primaryVehicleVin: String;
}
