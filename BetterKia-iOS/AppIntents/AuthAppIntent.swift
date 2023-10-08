//
//  AuthAppIntent.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 29.09.23.
//

import Foundation
import AppIntents

protocol AuthAppIntent: AppIntent {
}

extension AuthAppIntent {
    func canPerform() async throws -> IntentDialog? {
        AuthManager.shared.initialize()
        
        if !AuthManager.shared.isAuthenticated {
            let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String;
            return IntentDialog("Sorry, but you have to be signed in \(appName != nil ? "in the \(appName!) app" : "") to perform this action.")
        }
        
        return nil;
    }
}
