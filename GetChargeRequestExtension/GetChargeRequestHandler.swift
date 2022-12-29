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
      Task {
          var intentResponse = INGetCarPowerLevelStatusIntentResponse(
            code: .failure,
            userActivity: .none)
          
          let vehicleStatusData = await ApiClient.getVehicleStatus()
          
          if vehicleStatusData == nil {
              intentResponse = INGetCarPowerLevelStatusIntentResponse(
                code: .failure,
                userActivity: .none)
              
              completion(intentResponse)
              return;
          }
          
          let evStatus = vehicleStatusData!.evStatus
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
          let date = dateFormatter.date(from: vehicleStatusData!.time)!
          
          // only visible when charging
          intentResponse.dateOfLastStateUpdate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
          
          completion(intentResponse)
      }
  }

}
