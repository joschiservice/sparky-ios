//
//  GetChargeRequestHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 18.12.22.
//

import Foundation
import Intents
import os

struct VehicleStatusResponse: Decodable {
    let vehicleStatus: VehicleStatus
}

struct VehicleStatus : Decodable {
    let evStatus: EvStatus
}

struct EvStatus: Decodable {
    let batteryCharge: Bool
    let batteryStatus: Int
}

class GetChargeRequestHandler: NSObject, INGetCarPowerLevelStatusIntentHandling {
  func handle(intent: INGetCarPowerLevelStatusIntent,
              completion: @escaping (INGetCarPowerLevelStatusIntentResponse) -> Void) {
      
      let logger = Logger()
      logger.error("hi2")
      let url = URL(string: "https://better-kia.vcc-online.eu/api/hello")!
      
      var request = URLRequest(url: url)
      
      let auth = Data("2384z27834687236478f67826482|fjfiuwergisidjb4r734fsj3".utf8).base64EncodedString()
      request.setValue(auth, forHTTPHeaderField: "Authorization")
      
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          var intentResponse = INGetCarPowerLevelStatusIntentResponse(
            code: .failure,
            userActivity: .none)
          
          if let data = data, let vehicleStatusData = try? JSONDecoder().decode(VehicleStatusResponse.self, from: data) {
              let evStatus = vehicleStatusData.vehicleStatus.evStatus
              intentResponse = INGetCarPowerLevelStatusIntentResponse(
                  code: .success,
                userActivity: .none)
              intentResponse.chargePercentRemaining = Float(evStatus.batteryStatus) / 100.0
              intentResponse.activeConnector = INCar.ChargingConnectorType.gbtAC
              intentResponse.charging = evStatus.batteryCharge
          } else {
              intentResponse = INGetCarPowerLevelStatusIntentResponse(
                code: .failure,
                userActivity: .none)
          }
          completion(intentResponse)
      }
      
      task.resume()
  }

}
