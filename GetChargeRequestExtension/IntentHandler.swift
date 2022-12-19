//
//  IntentHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 18.12.22.
//

import Intents

class IntentHandler: INExtension {
  override func handler(for intent: INIntent) -> Any? {
    if intent is INGetCarPowerLevelStatusIntent {
      return GetChargeRequestHandler()
    } else if intent is INListCarsIntent {
        return GetCarsListHandler()
    } else if intent is INSetCarLockStatusIntent {
        return SetCarLockStatusHandler()
    } else if intent is StartClimateControlIntent {
        return StartClimateControlHandler()
    }
    return .none
  }
}
