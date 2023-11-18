//
//  PrimaryVehicleInfo.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

import Foundation

public struct PrimaryVehicleInfo: Decodable {
    let vin: String;
    
    let modelName: String;
    
    enum CodingKeys: String, CodingKey {
        case vin
        case modelName = "model"
    }
}
