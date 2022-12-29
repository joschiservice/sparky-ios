//
//  ApiClient.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 23.12.22.
//

import Foundation
import os

struct SimpleApiResponse: Decodable {
    let error: Bool
    let message: String
}

public class ApiClient {
    private static let _authHeader = Data("2384z27834687236478f67826482|fjfiuwergisidjb4r734fsj3".utf8).base64EncodedString()
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ApiClient")
    
    static func doRequest(urlString: String, method: String = "GET", jsonData: Data? = nil) async throws -> (Data, URLResponse) {
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": _authHeader
        ]

        let session = URLSession(configuration: sessionConfiguration)
        
        request.httpBody = jsonData
            
        logger.debug("Sending \(request.httpMethod ?? "GET") request to \(url)")
        
        return try await session.data(for: request)
    }
    
    static func registerDeviceToken(deviceToken: String) async -> Bool {
        let parameters: [String: String] = [
            "device_token": deviceToken,
            "topic": "common"
            ]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(parameters)
        
        do {
            let (_, response) = try await self.doRequest(urlString: "https://better-kia.vcc-online.eu/api/notifications/", method: "POST", jsonData: jsonData)
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if (httpResponse.statusCode == 204) {
                    return true;
                }
            }
        } catch {
            
        }
        logger.error("registerDeviceToken failed")
        return false;
    }
    
    static func registerForLiveChargingUpdates(liveActivitydeviceToken: String) async -> Bool {
        let parameters: [String: String] = [
            "device_token": liveActivitydeviceToken,
            "topic": "liveactivity-charging"
            ]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(parameters)
        
        do {
            let (_, response) = try await self.doRequest(urlString: "https://better-kia.vcc-online.eu/api/notifications/", method: "POST", jsonData: jsonData)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 204) {
                    return true;
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to register for live charging updates")
        return false;
    }
    
    static func getSchedules() {
        
    }
    
    static func saveSchedule() {
        
    }
    
    static func getVehicleStatus() async -> VehicleStatus? {
        do {
            let (data, response) = try await self.doRequest(urlString: "https://better-kia.vcc-online.eu/api/hello")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    return try? JSONDecoder().decode(VehicleStatus.self, from: data);
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to register for live charging updates")
        return nil;
    }
    
    static func lockVehicle() async -> Bool {
        do {
            let (data, response) = try await self.doRequest(urlString: "https://better-kia.vcc-online.eu/api/lock")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(SimpleApiResponse.self, from: data)
                    return apiResponse != nil && apiResponse?.error == false && apiResponse?.message == "Lock successful";
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to lock vehicle")
        return false;
    }
    
    static func unlockVehicle() async -> Bool {
        do {
            let (data, response) = try await self.doRequest(urlString: "https://better-kia.vcc-online.eu/api/unlock")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(SimpleApiResponse.self, from: data)
                    return apiResponse != nil && apiResponse?.error == false && apiResponse?.message == "Unlock successful";
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to unlock vehicle")
        return false;
    }
}
