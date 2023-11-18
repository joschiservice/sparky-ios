//
//  VehicleIdentifaction.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

import Foundation

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
