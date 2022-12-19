//
//  SetCarLockStatusHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 19.12.22.
//

import Foundation
import Intents
import os
import UIKit

// Not available in Germany? Cant test it
class SetCarLockStatusHandler: NSObject, INSetCarLockStatusIntentHandling {
  func handle(intent: INSetCarLockStatusIntent,
              completion: @escaping (INSetCarLockStatusIntentResponse) -> Void) {
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")
      logger.debug("Executing SetCarLockStatusHandler...")
      let response = INSetCarLockStatusIntentResponse(code: .success, userActivity: .none)
      
      completion(response)
  }

}
