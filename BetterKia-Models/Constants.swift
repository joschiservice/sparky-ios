//
//  Constants.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 17.11.23.
//

import Foundation

/**
 True, if app is being previewed in the XCode UI preview canvas
 */
public let IS_DEMO_MODE = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil;

/**
 Maximum allowed age for vehicle data (in minutes).
 */
public let MAX_VEHICLE_DATA_AGE = 5;
