//
//  ScheduleEntry.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 29.12.22.
//

import Foundation
import SwiftUI

struct WeekDayToggleData {
    public let shortName: String;
    public let getIsActiveBinding: (_: Binding<Schedule>) -> Binding<Bool>;
    
    init(_ shortName: String, _ getIsActiveBinding: @escaping (_: Binding<Schedule>) -> Binding<Bool>) {
        self.shortName = shortName
        self.getIsActiveBinding = getIsActiveBinding
    }
}

struct ScheduleEntry: View {
    @State private var isOn = false
    @State private var isAlertPresented = false
    @State private var newScheduleName = ""
    
    static let Weekdays: [WeekDayToggleData] = [
        WeekDayToggleData("Mo", { s in s.isActiveOnMonday }),
        WeekDayToggleData("Tu", { s in s.isActiveOnTuesday }),
        WeekDayToggleData("We", { s in s.isActiveOnWednesday }),
        WeekDayToggleData("Th", { s in s.isActiveOnThursday }),
        WeekDayToggleData("Fr", { s in s.isActiveOnFriday }),
        WeekDayToggleData("Sa", { s in s.isActiveOnSaturday }),
        WeekDayToggleData("Su", { s in s.isActiveOnSunday })
    ];
    
    var schedule: Binding<Schedule>
    
    var body: some View {
        GroupBox(label:
                    HStack {
            Label(schedule.name.wrappedValue, systemImage: "calendar.badge.clock")
                .onTapGesture {
                    newScheduleName = schedule.name.wrappedValue
                    isAlertPresented = true
                }
                .alert("Change name for the schedule", isPresented: $isAlertPresented) {
                    TextField("Untitled Schedule", text: $newScheduleName)
                            Button("Cancel", role: .cancel) { }
                    Button("Save") {
                        schedule.name.wrappedValue = newScheduleName
                    }
                        }
        }
        ) {
            VStack(spacing: 20) {
                HStack {
                    ForEach(ScheduleEntry.Weekdays, id: \.shortName) {weekday in
                        Toggle(isOn: weekday.getIsActiveBinding(schedule)) {
                            Text(weekday.shortName)
                        }
                        .toggleStyle(.button)
                        .aspectRatio(contentMode: .fill)
                    }
                }
                Toggle(isOn: schedule.isActivated) {
                    Label("Activate Air Conditioning", systemImage: "air.conditioner.vertical")
                    Text("Air Conditioning starts approximitly 15 minutes before depature")
                }
                DatePicker(
                        selection: schedule.departureTime,
                        displayedComponents: [.hourAndMinute]
                ) {
                    Label("Departure Time", systemImage: "clock")
                }
            }
        }
    }
}
