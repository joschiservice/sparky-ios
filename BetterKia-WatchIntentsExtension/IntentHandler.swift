//
//  IntentHandler.swift
//  WatchIntentsExtension
//
//  Created by Joschua Haß on 19.12.22.
//

import Intents

class IntentHandler: INExtension {
  override func handler(for intent: INIntent) -> Any? {
    if intent is INGetCarPowerLevelStatusIntent {
      return GetChargeRequestHandler()
    } else if intent is INSetCarLockStatusIntent {
        return SetCarLockStatusHandler()
    }
    return .none
  }
}
