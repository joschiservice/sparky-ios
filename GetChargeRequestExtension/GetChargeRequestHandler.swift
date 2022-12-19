//
//  GetChargeRequestHandler.swift
//  GetChargeRequestExtension
//
//  Created by Joschua Haß on 18.12.22.
//

import Foundation
import Intents
import os


class GetChargeRequestHandler: NSObject, INGetCarPowerLevelStatusIntentHandling {
  func handle(intent: INGetCarPowerLevelStatusIntent,
              completion: @escaping (INGetCarPowerLevelStatusIntentResponse) -> Void) {
      
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")
      
      let url = URL(string: "https://better-kia.vcc-online.eu/api/hello")!
      
      var request = URLRequest(url: url)
      
      let auth = Data("2384z27834687236478f67826482|fjfiuwergisidjb4r734fsj3".utf8).base64EncodedString()
      request.setValue(auth, forHTTPHeaderField: "Authorization")
      
      logger.debug("Sending request to \(url)")
      
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          var intentResponse = INGetCarPowerLevelStatusIntentResponse(
            code: .failure,
            userActivity: .none)
          
          if let data = data, let vehicleStatusData = try? JSONDecoder().decode(VehicleStatusResponse.self, from: data) {
              let evStatus = vehicleStatusData.vehicleStatus.evStatus
              intentResponse = INGetCarPowerLevelStatusIntentResponse(
                  code: .success,
                userActivity: .none)
              intentResponse.carIdentifier = "kia_e_soul_293"
              intentResponse.chargePercentRemaining = Float(evStatus.batteryStatus) / 100.0
              if evStatus.drvDistance.count > 0 {
                  let distanceRemaining = Measurement(value: Double((evStatus.drvDistance.first?.rangeByFuel.totalAvailableRange.value)!), unit: UnitLength.kilometers)
                  intentResponse.distanceRemainingElectric = distanceRemaining
                  intentResponse.distanceRemaining = distanceRemaining
              }
              
              // Idk if this is even used anywhere
              let maximumDistance = Measurement(value: 452, unit: UnitLength.kilometers)
              intentResponse.maximumDistance = maximumDistance
              intentResponse.maximumDistanceElectric = maximumDistance
              
              //intentResponse.activeConnector = INCar.ChargingConnectorType.gbtAC
              intentResponse.charging = evStatus.batteryCharge
              

              let dateFormatter = DateFormatter()
              dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
              dateFormatter.dateFormat = "yyyyMMddHHmmss"
              dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
              let date = dateFormatter.date(from:vehicleStatusData.vehicleStatus.time)!
              
              // only visible when charging
              intentResponse.dateOfLastStateUpdate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
              
              logger.debug("Successfully proceesed request")
          } else {
              intentResponse = INGetCarPowerLevelStatusIntentResponse(
                code: .failure,
                userActivity: .none)
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
