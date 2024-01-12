//
//  ConsumptionCategoryEntry.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 21.11.23.
//

import Foundation

public struct ConsumptionCategoryEntry : Decodable {
    let category: String
    let consumedWh: Int
}
