//
//  EvStatus.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

public struct EvStatus: Codable {
    let batteryCharge: Bool
    let batteryStatus: Int
    let drvDistance : [DriveDistance]
}
