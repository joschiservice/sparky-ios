//
//  StartClimateControlHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 19.12.22.
//

import Foundation
import Intents
import os
import UIKit

class StartClimateControlHandler: NSObject, StartClimateControlIntentHandling {
  func handle(intent: StartClimateControlIntent,
              completion: @escaping (StartClimateControlIntentResponse) -> Void) {
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")
      logger.debug("hi33312")
      let response = StartClimateControlIntentResponse(code: .success, userActivity: .none)
      
      completion(response)
  }

}

