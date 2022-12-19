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

struct SimpleApiResponse: Decodable {
    let error: Bool
    let message: String
}

// Not available in Germany? Cant test it
class SetCarLockStatusHandler: NSObject, INSetCarLockStatusIntentHandling {
  func handle(intent: INSetCarLockStatusIntent,
              completion: @escaping (INSetCarLockStatusIntentResponse) -> Void) {
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")
      logger.debug("Executing SetCarLockStatusHandler...")
      var intentResponse = INSetCarLockStatusIntentResponse(code: .failure, userActivity: .none)
      
      var action = "unlock"
      
      if intent.locked ?? false {
          action = "lock"
      }
      
      let url = URL(string: "https://better-kia.vcc-online.eu/api/" + action)!
      
      var request = URLRequest(url: url)
      
      let auth = Data("2384z27834687236478f67826482|fjfiuwergisidjb4r734fsj3".utf8).base64EncodedString()
      request.setValue(auth, forHTTPHeaderField: "Authorization")
      
      logger.debug("Sending request to \(url)")
      
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          if let data = data, let lockStatusData = try? JSONDecoder().decode(SimpleApiResponse.self, from: data) {
              
              if lockStatusData.error == false {
                  intentResponse = INSetCarLockStatusIntentResponse(
                    code: .success,
                    userActivity: .none)
                  logger.debug("Successfully proceesed request")
              } else {
                  logger.debug("Error: \(lockStatusData.message)")
              }
          } else {
              if data == nil {
                  logger.error("Error: no data received")
              } else {
                  logger.error("Error: Request response data: \(String(decoding: data!, as: UTF8.self))")
              }
          }
          completion(intentResponse)
      }
      
      task.resume()
  }

}
