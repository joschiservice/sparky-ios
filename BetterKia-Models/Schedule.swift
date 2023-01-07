//
//  Schedule.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 29.12.22.
//

import Foundation

public struct Schedule: Hashable {
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
    
    var hasAnyValueChanged = false
    
    mutating func handleDidSet() {
        self.hasAnyValueChanged = true
    }
}

// Data directly returned by the API
public struct ScheduleData: Decodable {
    let id: Int
    let isActive: Bool
    let departureTime: Date
    let activeDays: [WeekdayData]
    
    func toSchedule() -> Schedule {
        var schedule = Schedule(id: self.id, name: "", isActivated: self.isActive, departureTime: self.departureTime)
        
        for weekday in self.activeDays {
            switch weekday.name {
            case "monday":
                schedule.isActiveOnMonday = true
            case "tuesday":
                schedule.isActiveOnTuesday = true
            case "wednesday":
                schedule.isActiveOnWednesday = true
            case "thursday":
                schedule.isActiveOnThursday = true
            case "friday":
                schedule.isActiveOnFriday = true
            case "saturday":
                schedule.isActiveOnSaturday = true
            case "sunday":
                schedule.isActiveOnSunday = true
            default:
                break
            }
        }
        
        // Reset because value will be changed due to the previous for loop with switching
        schedule.hasAnyValueChanged = false
        
        return schedule
    }
}

public struct WeekdayData: Decodable {
    let id: Int
    let name: String
}
