//
//  AuthManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 16.02.23.
//

import Foundation

public class AuthManager : ObservableObject {
    public static let shared = AuthManager()
    
    /**
     Use this function to authenticate a new user
     */
    public func authenticateUsingKia(email: String, password: String) async -> Bool {
        return true;
    }
    
    /**
     Use this function to authenticate a new user using 'Sign in with Apple'
     */
    public func authenticateUsingApple() async -> Bool {
        return true;
    }
}
