//
//  AuthManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 16.02.23.
//

import Foundation
import WidgetKit

public class AuthManager : ObservableObject, ApiClientDelegate {
    public static let shared = AuthManager()
    
    @Published var isAuthenticated = false;
    
    public func initialize() {
        isAuthenticated = readTokens();
        
        ApiClient.delegate = self;
    }
    
    /**
     Use this function to authenticate a new user
     */
    public func authenticateUsingKia(email: String, password: String) async -> Bool {
        let result = await ApiClient.authenticateUsingKia(email: email, password: password);
        
        if (result == nil) {
            return false;
        }
        
        let storeTokenResult = storeTokens(accessToken: result!.accessToken, refreshToken: result!.refreshToken);
        
        if (storeTokenResult == false) {
            return false;
        }
        
        ApiClient.accessToken = result!.accessToken;
        ApiClient.refreshToken = result!.refreshToken;
        
        DispatchQueue.main.async {
            self.isAuthenticated = true;
        }
        
        // Reload widgets to display data
        WidgetCenter.shared.reloadAllTimelines()
        
        return true;
    }
    
    public func signOut() {
        // Clear tokens in keychain
        _ = storeTokens(accessToken: "", refreshToken: "")
        
        // Clear tokens in memory
        ApiClient.accessToken = "";
        ApiClient.refreshToken = "";
        
        // Update UI
        DispatchQueue.main.async {
            self.isAuthenticated = false;
        }
    }
    
    private func storeTokens(accessToken: String, refreshToken: String) -> Bool {
        print("Saving new tokens. Access Token: '\(accessToken)' Refresh Token: '\(refreshToken)'");
        
        let accessTokenResult = saveDataInKeychain(data: Data(accessToken.utf8), service: "access-token", account: "better-kia");
        let refreshTokenResult = saveDataInKeychain(data: Data(refreshToken.utf8), service: "refresh-token", account: "better-kia");
        
        return accessTokenResult && refreshTokenResult;
    }
    
    private func readTokens() -> Bool {
        let accessTokenData = readDataInKeychain(service: "access-token", account: "better-kia");
        
        if (accessTokenData == nil) {
            return false;
        }
        
        ApiClient.accessToken = String(decoding: accessTokenData!, as: UTF8.self);
        
        let refreshTokenData = readDataInKeychain(service: "refresh-token", account: "better-kia");
        
        if (refreshTokenData == nil) {
            return false;
        }
        
        ApiClient.refreshToken = String(decoding: refreshTokenData!, as: UTF8.self);
        
        return true;
    }
    
    private func saveDataInKeychain(data: Data, service: String, account: String) -> Bool {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: "group.de.thevisualcablecollective.BetterKia.appgroup",
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        ] as [CFString : Any] as CFDictionary
            
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
            
        if status == errSecDuplicateItem {
                // Item already exist, thus update it.
                let query = [
                    kSecAttrService: service,
                    kSecAttrAccount: account,
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccessGroup: "group.de.thevisualcablecollective.BetterKia.appgroup",
                ] as [CFString : Any] as CFDictionary

            let attributesToUpdate = [kSecValueData: data, kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,] as [CFString : Any] as CFDictionary

                // Update existing item
                SecItemUpdate(query, attributesToUpdate)
        } else if status != errSecSuccess {
            print("Error: An error occured while saving data in the keychain (\(account).\(service)) \(status)")
            return false;
        }
        
        return true;
    }
    
    func readDataInKeychain(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessGroup: "group.de.thevisualcablecollective.BetterKia.appgroup",
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    /**
     Use this function to authenticate a new user using 'Sign in with Apple'
     */
    public func authenticateUsingApple() async -> Bool {
        return true;
    }
    
    public func newTokensReceived(accessToken: String, refreshToken: String) {
        _ = storeTokens(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    public func sessionExpired() {
        isAuthenticated = false;
    }
}
