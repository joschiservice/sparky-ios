//
//  GetCarsListHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 19.12.22.
//

import Foundation
import Intents
import os
import UIKit

// Not available in Germany? Cant test it
class GetCarsListHandler: NSObject, INListCarsIntentHandling {
  func handle(intent: INListCarsIntent,
              completion: @escaping (INListCarsIntentResponse) -> Void) {
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")
      logger.debug("hi12")
      let response = INListCarsIntentResponse(code: .success, userActivity: .none)
      
      let car = INCar(carIdentifier: "kia_e_soul_293", displayName: "Kia e-Soul", year: "2019", make: "Kia", model: "e-Soul", color: UIColor.red.cgColor, headUnit: nil, supportedChargingConnectors: [.ccs2, .gbtAC])
      
      response.cars = [car]
      
      completion(response)
  }

}

