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

public protocol ApiClientDelegate : AnyObject {
    func newTokensReceived(accessToken: String, refreshToken: String)
    func sessionExpired()
}

public class ApiClient {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ApiClient")
    
    private static let serverUrl = "https://better-kia-api.vercel.app/"
    
    public static var accessToken = ""
    
    public static var refreshToken = ""
    
    public static weak var delegate : ApiClientDelegate?
    
    /**
     Is true if a refresh token request is pending
     */
    private static var isRefreshingToken = false
    
    static func doRequest(urlString: String, method: String = "GET", jsonData: Data? = nil) async throws -> (Data, URLResponse) {
        if IS_DEMO_MODE {
            return (Data(), URLResponse())
        }
        
        var requestResult = try await doRequestInternal(urlString: urlString, method: method, jsonData: jsonData)
        let requestResponse = requestResult.1;
        
        if let httpResponse = requestResponse as? HTTPURLResponse {
            switch httpResponse.statusCode {
            // Unauthorized
            case 401:
                // Wait, if a token refresh request has already been sent
                if isRefreshingToken {
                    while isRefreshingToken {
                        usleep(100);
                    }
                    
                    return try await doRequestInternal(urlString: urlString, method: method, jsonData: jsonData);
                }
                
                // Start refresh token operation
                isRefreshingToken = true;
                
                logger.debug("Request to \(urlString) returned Unauthorized. Refreshing access token...")
                
                let jsonEncoder = JSONEncoder()
                jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
                let jsonDataRefresh = try? jsonEncoder.encode(RefreshTokenRequest(refreshToken: refreshToken))
                
                let (refreshTokenData, refreshTokenResponse) = try await doRequestInternal(urlString: "\(serverUrl)api/auth/refresh", method: "POST", jsonData: jsonDataRefresh);
                
                guard let refreshTokenhHttpResponse = refreshTokenResponse as? HTTPURLResponse else {
                    logger.debug("Session expired and refresh token request failed (unexpected type)");
                    
                    // log out user
                    delegate?.sessionExpired()
                    
                    isRefreshingToken = false;
                    
                    throw SessionExpiredError.runtimeError("The refresh token of the session has expired.");
                }
                
                if refreshTokenhHttpResponse.statusCode != 200 {
                    logger.debug("Session expired and couldn't be restored.");
                    logger.debug("Refresh token response: \(String(decoding: refreshTokenData, as: UTF8.self))");
                    
                    // log out user
                    delegate?.sessionExpired()
                    
                    isRefreshingToken = false;
                    
                    throw SessionExpiredError.runtimeError("The refresh token of the session has expired.")
                }
                
                let refreshTokenParsedData = try? JSONDecoder().decode(RefreshTokenResponse.self, from: refreshTokenData)
                
                // Store new tokens
                accessToken = refreshTokenParsedData!.accessToken;
                refreshToken = refreshTokenParsedData!.refreshToken;
                
                delegate?.newTokensReceived(accessToken: accessToken, refreshToken: refreshToken);
                
                isRefreshingToken = false;
                
                requestResult = try await doRequestInternal(urlString: urlString, method: method, jsonData: jsonData)
                
            default:
                break;
            }
        }
        
        return requestResult;
    }
    
    private static func doRequestInternal(urlString: String, method: String = "GET", jsonData: Data? = nil) async throws -> (Data, URLResponse) {
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        
        // Set Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = method
        
        let sessionConfiguration = URLSessionConfiguration.default;

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]

        let session = URLSession(configuration: sessionConfiguration)
        
        request.httpBody = jsonData
            
        logger.debug("Sending \(request.httpMethod ?? "GET") request to \(url)")
        
        return try await session.data(for: request);
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
    
    static func getVehicles() async -> [VehicleIdentification]? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/account/vehicles")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do {
                        let decoder =  JSONDecoder()
                        
                        return try decoder.decode([VehicleIdentification].self, from: data)
                    } catch {
                        logger.error("GetVehicles: Data couldn't be converted: \(error)")
                        logger.debug("GetVehicles: Response Data: \(String(decoding: data, as: UTF8.self))")
                    }
                } else {
                    logger.error("GetVehicles: Status code was invalid")
                }
            }
        } catch {
            
        }
        
        logger.error("GetVehicles: Failed to retrieve data")
        return nil
    }
    
    static func getPrimaryVehicle() async -> PrimaryVehicleInfo? {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/account/vehicle")
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do {
                        let decoder =  JSONDecoder()
                        
                        logger.debug("GetVehicles: Response Data: \(String(decoding: data, as: UTF8.self))")
                        
                        return try decoder.decode(PrimaryVehicleInfo.self, from: data)
                    } catch {
                        logger.error("GetVehicles: Data couldn't be converted: \(error)")
                        logger.debug("GetVehicles: Response Data: \(String(decoding: data, as: UTF8.self))")
                    }
                } else {
                    logger.error("GetVehicles: Status code was invalid")
                }
            }
        } catch {
            
        }
        
        logger.error("GetVehicles: Failed to retrieve data")
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
    
    static func setPrimaryVehicle(vin: String) async -> Bool {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let postBody = SetPrimaryVehicleData(primaryVehicleVin: vin);
        
        let jsonData = try? jsonEncoder.encode(postBody)
        
        do {
            let url = serverUrl + "api/account/set-primary-vehicle"
            let method = "POST"
            let (data, response) = try await self.doRequest(urlString: url, method: method, jsonData: jsonData)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 204) {
                    logger.error("SetPrimaryVehicle: Response: \(String(decoding: data, as: UTF8.self))")
                    return true
                } else {
                    logger.error("SetPrimaryVehicle: Status code was invalid")
                    logger.error("SetPrimaryVehicle: Response: \(String(decoding: data, as: UTF8.self))")
                }
            }
        } catch {
            
        }
        
        logger.error("SetPrimaryVehicle: Failed!")
        return false
    }
    
    static func getVehicleStatus(refreshData: Bool = false) async -> CommonResponse<VehicleStatus> {
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/data" + (refreshData ? "?forceRefresh=true" : ""))
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let decoder =  JSONDecoder()
                    
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    decoder.dateDecodingStrategy =  .formatted(formatter)
                    
                    let responseData = try? decoder.decode(VehicleStatus.self, from: data);
                    return CommonResponse(failed: false, error: .NoError, data: responseData);
                } else {
                    logger.error("GetVehicleStatus: Status Code: \(httpResponse.statusCode)");
                    logger.error("GetVehicleStatus: Response: \(String(decoding: data, as: UTF8.self))")
                    return unexpectedResponseHandler(data);
                }
            }
        } catch let error {
            logger.error("GetVehicleStatus: Error: \(error.localizedDescription)")
        }
        
        logger.error("Failed to get vehicle status")
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
        } else if (errorData?.code == "MISSING_BRAND_SESSION") {
            error = ApiErrorType.InvalidBrandSession;
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
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/lock")
            
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
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/unlock")
            
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
    
    static func startVehicle(data: StartVehicleRequest) async -> CommandResponse? {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try? jsonEncoder.encode(data);
            
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/vehicle/start", method: "POST", jsonData: jsonData)
            
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
    
    static func authenticateUsingKia(email: String, password: String) async -> SignInResponse? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try? jsonEncoder.encode(SignInUsingKiaRequest(email: email, password: password))
        
        do {
            let (data, response) = try await self.doRequest(urlString: serverUrl + "api/auth/signin/kia", method: "POST", jsonData: jsonData)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let apiResponse = try? JSONDecoder().decode(SignInResponse.self, from: data)
                    return apiResponse
                } else {
                    logger.error("Status Code: \(httpResponse.statusCode)");
                    logger.error("Response: \(String(decoding: data, as: UTF8.self))")
                }
            }
        } catch {
            
        }
        
        logger.error("Failed to login using Kia")
        return nil;
    }
}
