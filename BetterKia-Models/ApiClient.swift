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

struct ApiErrorResponse: Decodable {
    let error: Bool
    let code: String
}

struct CommandResponse: Decodable {
    let error: Bool
    let code: String
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
    
    static func getVehicleStatus(refreshData: Bool = false) async -> CommonResponse<VehicleStatus> {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/hello" + (refreshData ? "?forceRefresh=true" : ""))
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let responseData = try? JSONDecoder().decode(VehicleStatus.self, from: data);
                    return CommonResponse(failed: false, error: .NoError, data: responseData);
                } else {
                    return unexpectedResponseHandler(data);
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to get vehicle charging status")
        return CommonResponse(failed: true, error: .UnknownError, data: nil);
    }
    
    private static func unexpectedResponseHandler<T>(_ data: Data) -> CommonResponse<T> {
        let errorData = try? JSONDecoder().decode(ApiErrorResponse.self, from: data);
        
        if (errorData == nil) {
            return CommonResponse<T>(failed: true, error: .UnknownError, data: nil);
        }
        
        var error = ApiErrorType.UnknownError;
        
        if (errorData?.code == "RATE_LIMITED_BY_OEM") {
            error = ApiErrorType.RateLimitedByOEM;
        }
        
        return CommonResponse(failed: true, error: error, data: nil);
    }
    
    static func getVehicleLocation() async -> VehicleLocationResponse? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/location")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    return try? JSONDecoder().decode(VehicleLocationResponse.self, from: data);
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to get vehicle location")
        return nil;
    }
    
    static func lockVehicle() async -> CommandResponse? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/lock")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(CommandResponse.self, from: data)
                    return apiResponse;
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to lock vehicle")
        return nil;
    }
    
    static func unlockVehicle() async -> CommandResponse? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/unlock")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(CommandResponse.self, from: data)
                    return apiResponse;
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to unlock vehicle")
        return nil;
    }
    
    static func startVehicle() async -> CommandResponse? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/start")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(CommandResponse.self, from: data)
                    logger.log("Start vehicle result: \(apiResponse?.code ?? "")");
                    return apiResponse;
                } else {
                    logger.error("Status Code: \(httpResponse.statusCode)");
                    logger.error("Response: \(String(decoding: data, as: UTF8.self))")
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to start vehicle")
        return nil;
    }
    
    static func stopVehicle() async -> CommandResponse? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/stop")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(CommandResponse.self, from: data)
                    logger.log("Stop vehicle result: \(apiResponse?.code ?? "")");
                    return apiResponse
                } else {
                    logger.error("Status Code: \(httpResponse.statusCode)");
                    logger.error("Response: \(String(decoding: data, as: UTF8.self))")
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to stop vehicle")
        return nil;
    }
}
