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
      Task {
          AuthManager.shared.initialize()
          
          var intentResponse = INSetCarLockStatusIntentResponse(code: .failure, userActivity: .none)
          
          var wasActionSuccessful = false
          
          if intent.locked ?? false {
              var result = await ApiClient.lockVehicle();
              wasActionSuccessful = result != nil && !result!.error;
          } else {
              var result = await ApiClient.unlockVehicle();
              wasActionSuccessful = result != nil && !result!.error;
          }
          
          if wasActionSuccessful {
              intentResponse = INSetCarLockStatusIntentResponse(
                code: .success,
                userActivity: .none)
          }
          
          completion(intentResponse)
      }
  }

}
