//
//  ConfigManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 20.11.23.
//

import Foundation

/**
 Contains user settings and configuration. Don't store sensitive information here!
 */
public class ConfigManager: ObservableObject {
    public static let shared = ConfigManager();
    
    // MARK: - Properties
    var hvacTargetTemp: Double {
        get {
            return getValue(forKey: "HVAC_TARGET_TEMP", defaultValue: 22.0)
        }
        
        set {
            return setValue(forKey: "HVAC_TARGET_TEMP", value: newValue)
        }
    }
    
    // MARK: Cache
    private var cache: [String: Any] = [:]
    
    private func getValue<T>(forKey: String, defaultValue: T) -> T {
        guard let cacheValue = cache[forKey] as? T else {
            guard let storedValue = UserDefaults.standard.object(forKey: forKey) as? T else {
                setValue(forKey: forKey, value: defaultValue)
                return defaultValue
            }
            return storedValue
        }
        return cacheValue
    }
    
    private func setValue<T>(forKey: String, value: T) -> Void {
        UserDefaults.standard.set(value, forKey: forKey)
        cache[forKey] = value
    }
}
