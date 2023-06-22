//
//  ScheduleEntry.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 29.12.22.
//

import Foundation
import SwiftUI

struct ScheduleEntry: View {
    @State private var isOn = false
    @State private var isAlertPresented = false
    @State private var newScheduleName = ""
    
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
                    Toggle(isOn: schedule.isActiveOnMonday) {
                            Text("Mo")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnTuesday) {
                            Text("Tu")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnWednesday) {
                            Text("We")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnThursday) {
                            Text("Th")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnFriday) {
                            Text("Fr")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnSaturday) {
                            Text("Sa")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnSunday) {
                            Text("So")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
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
