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
    
    var body: some View {
        VStack {
        }
    }
}

struct ClimateControlScheduleView: View {
    
    @State private var isLoading = true
    
    @State private var schedules: [Schedule] = []
    
    func loadSchedules() {
        Task {
            self.isLoading = true
            self.schedules = await ApiClient.getSchedules() ?? []
            self.isLoading = false
        }
    }
    
    var body: some View {
        NavigationStack {
            List ($schedules, id: \.self, editActions: .delete) {schedule in
                ScheduleEntry(schedule: schedule)
                    .listRowSeparator(.hidden)
            }
            .overlay(Group {
                if isLoading {
                    ProgressView()
                }
                else if schedules.isEmpty {
                                Text("No schedules created yet.")
                            }
                        })
            .refreshable {
                self.loadSchedules()
            }
            .listStyle(.plain)
            .navigationTitle("Schedules")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        schedules.append(Schedule(name: "Untitled Schedule"))
                        
                    }, label: {
                        Image(systemName: "calendar.badge.plus")
                        
                    })
                }
                
                if schedules.contains(where: { $0.hasAnyValueChanged }) {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            
                        }, label: {
                            Text("Save")
                        })
                    }
                }
            }
        }
        .onAppear(perform: self.loadSchedules)
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
