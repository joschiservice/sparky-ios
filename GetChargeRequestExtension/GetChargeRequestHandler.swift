//
//  GetChargeRequestHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 18.12.22.
//

import Foundation
import Intents

class GetChargeRequestHandler: NSObject, INGetCarPowerLevelStatusIntentHandling {
  func handle(intent: INGetCarPowerLevelStatusIntent,
              completion: @escaping (INGetCarPowerLevelStatusIntentResponse) -> Void) {
    let response = INGetCarPowerLevelStatusIntentResponse(
        code: .success,
      userActivity: .none)
      response.chargePercentRemaining = 0.73
      response.activeConnector = INCar.ChargingConnectorType.gbtAC
      response.charging = true
      response.minutesToFull = 12
    completion(response)
  }

}
