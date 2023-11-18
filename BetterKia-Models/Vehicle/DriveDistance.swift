//
//  DriveDistance.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

import Foundation

public struct DriveDistance: Codable {
    let rangeByFuel: RangeByFuel
}

public struct RangeByFuel: Codable {
    let totalAvailableRange: RangeData
}

public struct RangeData: Codable {
    let value: Int
    let unit: Int
}
