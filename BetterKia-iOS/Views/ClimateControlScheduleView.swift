//
//  ClimateControlScheduleView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 11.01.23.
//

import Foundation
import SwiftUI

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
    
    func saveItems() {
        Task {
            for scheduleItem in schedules.enumerated() {
                if (scheduleItem.element.hasAnyValueChanged) {
                    if (await ApiClient.saveSchedule(item: scheduleItem.element)) {
                        schedules[scheduleItem.offset].hasAnyValueChanged = false
                    }
                }
            }
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
                        Button(action: saveItems, label: {
                            Text("Save")
                        })
                    }
                }
            }
        }
        .onAppear(perform: self.loadSchedules)
    }
}
