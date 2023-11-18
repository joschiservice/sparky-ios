//
//  VehicleLocationResponse.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

public struct VehicleLocationResponse: Decodable {
    let error: Bool
    let message: VehicleLocation
}
