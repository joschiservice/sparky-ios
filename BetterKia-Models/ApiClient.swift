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
    
    private static let serverUrl = "https://better-kia-api.vercel.app/"
    
    static func doRequest(urlString: String, method: String = "GET", jsonData: Data? = nil) async throws -> (Data, URLResponse) {
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        
        // Set Headers
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
            let (_, response) = try await self.doRequest(urlString: serverUrl + "api/notifications/", method: "POST", jsonData: jsonData)
            
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
            let (_, response) = try await self.doRequest(urlString: serverUrl + "api/notifications/", method: "POST", jsonData: jsonData)
            
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
    
    static func getSchedules() async -> [Schedule]? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/climate-control-schedules")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do {
                        let decoder =  JSONDecoder()
                        
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        
                        decoder.dateDecodingStrategy =  .formatted(formatter)
                        
                        let scheduledata = try decoder.decode([ScheduleData].self, from: data)
                        var returnData: [Schedule] = []
                        
                        for entry in scheduledata {
                            returnData.append(entry.toSchedule())
                        }
                        
                        return returnData
                    } catch {
                        logger.error("GetSchedules: Data couldn't be converted: \(error)")
                        logger.debug("GetSchedules: Response Data: \(String(decoding: data, as: UTF8.self))")
                    }
                } else {
                    logger.error("GetSchedules: Status code was invalid")
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to retrieve charging schedules")
        return nil
    }
    
    static func saveSchedule(item: Schedule) async -> Bool {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try? jsonEncoder.encode(item.toScheduleActionData())
        
        do {
            var url = serverUrl + "api/climate-control-schedules/"
            var method = "POST"
            if (item.id != 0) {
                url += String(item.id) + "/"
                method = "PATCH"
            }
            let (data, response) = try await self.doRequest(urlString: url, method: method, jsonData: jsonData)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    logger.error("Response: \(String(decoding: data, as: UTF8.self))")
                    return true
                } else {
                    logger.error("SaveSchedule: Status code was invalid")
                    logger.error("Response: \(String(decoding: data, as: UTF8.self))")
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to save schedules")
        return false
    }
    
    static func getVehicleStatus() async -> VehicleStatus? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/hello")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    return try? JSONDecoder().decode(VehicleStatus.self, from: data);
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to get vehicle charging status")
        return nil;
    }
    
    static func lockVehicle() async -> Bool {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/lock")
            
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
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/unlock")
            
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
    
    static func startVehicle() async -> Bool {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/start")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(SimpleApiResponse.self, from: data)
                    logger.log("Start vehicle result: \(apiResponse?.message ?? "")");
                    return apiResponse != nil && apiResponse?.error == false;
                } else {
                    logger.error("Status Code: \(httpResponse.statusCode)");
                    logger.error("Response: \(String(decoding: data, as: UTF8.self))")
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to start vehicle")
        return false;
    }
}
