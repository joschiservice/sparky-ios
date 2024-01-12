//
//  VehicleHistoryEntry.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 21.11.23.
//

import Foundation

public struct VehicleHistoryEntry : Decodable {
    let id: String
    let vin: String
    let date: Date
    let distanceDrivenKm: Int
    let regenWh: Int
    let estimatedLossPercent: Int
    let batteryChargeEndOfDay: Int?
    let entries: [ConsumptionCategoryEntry]
}
