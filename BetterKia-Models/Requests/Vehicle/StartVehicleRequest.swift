//
//  StartVehicleRequest.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 17.11.23.
//

public struct StartVehicleRequest: Encodable {
    var temperature: Double;
    var defrost: Bool? = nil;
    var withLiveActivityTip: Bool;
    var durationMinutes: UInt;
    var heatedFeatures: Bool? = nil;
}
