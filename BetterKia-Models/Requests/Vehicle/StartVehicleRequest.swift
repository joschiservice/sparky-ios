//
//  StartVehicleRequest.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 17.11.23.
//

public struct StartVehicleRequest: Encodable {
    let temperature: UInt;
    let defrost: Bool? = nil;
    let withLiveActivityTip: Bool;
    let durationMinutes: UInt;
}
