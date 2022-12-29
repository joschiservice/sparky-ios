//
//  Schedule.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 29.12.22.
//

import Foundation

struct Schedule: Hashable {
    var id = 0
    
    var name: String { didSet { handleDidSet() }}
    var isActiveOnMonday = false { didSet { handleDidSet() }}
    var isActiveOnTuesday = false { didSet { handleDidSet() }}
    var isActiveOnWednesday = false { didSet { handleDidSet() }}
    var isActiveOnThursday = false { didSet { handleDidSet() }}
    var isActiveOnFriday = false { didSet { handleDidSet() }}
    var isActiveOnSaturday = false { didSet { handleDidSet() }}
    var isActiveOnSunday = false { didSet { handleDidSet() }}
    
    var isActivated = false { didSet { handleDidSet() }}
    
    var departureTime = Date() { didSet { handleDidSet() }}
    
    var valueChanged = false
    
    private(set) var hasAnyValueChanged = false
    
    mutating func handleDidSet() {
        print(self.hasAnyValueChanged)
        self.hasAnyValueChanged = true
    }
}
