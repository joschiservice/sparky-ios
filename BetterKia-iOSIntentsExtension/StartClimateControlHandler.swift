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

class StartClimateControlHandler: NSObject, StartPreconditioningIntentHandling {
    func resolveTemperature(for intent: StartPreconditioningIntent, with completion: @escaping (StartPreconditioningTemperatureResolutionResult) -> Void) {
        var result: StartPreconditioningTemperatureResolutionResult;
        
        if let temperature = intent.temperature {
            result = StartPreconditioningTemperatureResolutionResult.success(with: temperature.doubleValue)
        } else {
            result = StartPreconditioningTemperatureResolutionResult.needsValue();
        }
        
        completion(result);
    }
    
  func handle(intent: StartPreconditioningIntent,
              completion: @escaping (StartPreconditioningIntentResponse) -> Void) {
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")
      logger.debug("hi33312")
      let response = StartPreconditioningIntentResponse(code: .success, userActivity: .none)
      
      completion(response)
  }

}

