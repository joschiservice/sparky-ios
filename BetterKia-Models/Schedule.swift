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
    
    func toScheduleActionData() -> ScheduleActionData {
        
        // Convert time to server time
        var calendar = Calendar.current
        calendar.timeZone = .gmt
        
        let depatureTimeHour = calendar.component(.hour, from: departureTime)
        let depatureTimeMin = calendar.component(.minute, from: departureTime)
        
        var activeDaysConv: [String] = []
        
        if (isActiveOnMonday) { activeDaysConv.append("monday") }
        if (isActiveOnTuesday) { activeDaysConv.append("tuesday") }
        if (isActiveOnWednesday) { activeDaysConv.append("wednesday") }
        if (isActiveOnThursday) { activeDaysConv.append("thursday") }
        if (isActiveOnFriday) { activeDaysConv.append("friday") }
        if (isActiveOnSaturday) { activeDaysConv.append("saturday") }
        if (isActiveOnSunday) { activeDaysConv.append("sunday") }
        
        return ScheduleActionData(id: self.id, name: self.name, isActive: self.isActivated, departureTimeHour: depatureTimeHour, departureTimeMinute: depatureTimeMin, activeDays: activeDaysConv)
    }
}

// Data directly returned by the API
public struct ScheduleData: Decodable {
    let id: Int
    let name: String
    let isActive: Bool
    let departureTime: Date
    let activeDays: [WeekdayData]
    
    func toSchedule() -> Schedule {
        var schedule = Schedule(id: self.id, name: self.name, isActivated: self.isActive, departureTime: self.departureTime)
        
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

public struct ScheduleActionData: Encodable {
    let id: Int
    let name: String
    let isActive: Bool
    let departureTimeHour: Int
    let departureTimeMinute: Int
    let activeDays: [String]
}
