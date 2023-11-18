//
//  VehicleLocation.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

public struct VehicleLocation : Decodable {
    let latitude: Double
    let longitude: Double
    let speed: VehicleSpeed
    let heading: Double
}
