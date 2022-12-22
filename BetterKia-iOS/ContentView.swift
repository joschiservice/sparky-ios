//
//  ContentView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 18.12.22.
//

import SwiftUI
import os
import WidgetKit
import ActivityKit

struct ExampleView: View {
    @State var deliveryActivity: Activity<LiveChargeStatusWidgetAttributes>?
    
    var body: some View {
        VStack {
            Button("test") {
                if ActivityAuthorizationInfo().areActivitiesEnabled {
                    var future = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                    let date = Date.now...future
                    let initialContentState = LiveChargeStatusWidgetAttributes.ContentState(batteryCharge: 33, minRemaining: 33, chargeLimit: 33, chargedKw: 33)
                    let activityAttributes = LiveChargeStatusWidgetAttributes()
                    
                    let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)
                    
                    do {
                        self.deliveryActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
                        } catch (let error) {
                            print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                        }
                }
            }
        }
    }
}

struct ScheduleEntry: View {
    @State private var isOn = false
    
    let schedule: Binding<ScheduleData>
    
    var body: some View {
        GroupBox(label:
                    Label(schedule.name.wrappedValue, systemImage: "calendar.badge.clock")
        ) {
            VStack(spacing: 20) {
                HStack {
                    Toggle(isOn: schedule.isActiveOnMonday) {
                            Text("Mo")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnTuesday) {
                            Text("Di")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnWednesday) {
                            Text("Mi")
                    }
                    .toggleStyle(.button)
                    .aspectRatio(contentMode: .fill)
                    
                    Toggle(isOn: schedule.isActiveOnThursday) {
                            Text("Do")
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

struct ScheduleData: Hashable {
    var name: String
    var isActiveOnMonday = false
    var isActiveOnTuesday = false
    var isActiveOnWednesday = false
    var isActiveOnThursday = false
    var isActiveOnFriday = false
    var isActiveOnSaturday = false
    var isActiveOnSunday = false
    
    var isActivated = false
    
    var departureTime = Date()
}

struct ClimateControlScheduleView: View {
    
    @State private var schedules = [ScheduleData(name: "Schedule 1")]
    
    var body: some View {
        NavigationStack {
            List ($schedules, id: \.self, editActions: .delete) {schedule in
                ScheduleEntry(schedule: schedule)
                    .listRowSeparator(.hidden)
            }
            .refreshable {
                            print("Do your refresh work here")
                
            }
            .listStyle(.plain)
            .navigationTitle("Schedules")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        schedules.append(ScheduleData(name: "Untitled Schedule"))
                        
                    }, label: {
                        Image(systemName: "calendar.badge.plus")
                        
                    })
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        schedules.append(ScheduleData(name: "Untitled Schedule"))
                        
                    }, label: {
                        Text("Save")
                    })
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ClimateControlScheduleView()
                .tabItem {
                    Label("Schedules", systemImage: "calendar")
                }
            ExampleView()
                .tabItem {
                    Label("Sent", systemImage: "tray.and.arrow.up.fill")
                }
            ExampleView()
                .badge("!")
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
