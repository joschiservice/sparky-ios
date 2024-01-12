//
//  HistoryView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 14.05.23.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    
    @State private var isLoading = false
    @State private var data: [VehicleHistoryEntry] = []
    @State private var hasLoadedData = false
    
    func loadData(force: Bool = false) {
        if (isLoading || (hasLoadedData && !force)) {
            return
        }
        
        isLoading = true
        
        Task {
            let response = await ApiClient.getVehicleHistory()
            
            if response.failed || response.data == nil {
                self.isLoading = false
                self.hasLoadedData = true
                AlertManager.shared.publishAlert("History: Couldn't load data", description: "An error occured while loading the history data. Please try again later")
                return
            }
            
            self.isLoading = false
            self.hasLoadedData = true
            self.data = response.data!
        }
    }
    
    func getFormattedDate(entry: VehicleHistoryEntry) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let formattedDate = formatter.string(for: entry.date)
        
        return formattedDate != nil ? formattedDate! : "n/a"
    }
    
    var body: some View {
        NavigationStack {
            List ($data, id: \.id) {entry in
                Section(getFormattedDate(entry: entry.wrappedValue)) {
                    HistoryEntry(entry: entry.wrappedValue)
                        .listRowSeparator(.hidden)
                }
            }
            .overlay(Group {
                if isLoading {
                    ProgressView()
                }
                })
                    .refreshable {
                        self.loadData(force: true)
                    }
                    .listStyle(.plain)
                    .navigationTitle("History")
            }
        .onAppear {
            self.loadData()
        }
            }
            }


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

struct HistoryEntry: View {
    public var entry: VehicleHistoryEntry
    
    var body: some View {
        GroupBox(label:
                    HStack {
            Label("07:45 - 08:01", systemImage: "steeringwheel")
            
            Spacer()
            
            Text("-\(entry.estimatedLossPercent)%")
                .opacity(0.4)
        }
        ) {
            VStack(spacing: 0) {
                GeometryReader { metrics in
                    ZStack (alignment: .center) {
                        RoundedRectangle(cornerSize: CGSize(width: 2, height: 4))
                            .size(width: metrics.size.width, height: 6)
                            .foregroundColor(Color(UIColor.systemGray5))
                        RoundedRectangle(cornerSize: CGSize(width: 2, height: 4))
                            .size(width: (CGFloat(80) / 100.0) * metrics.size.width, height: 6)
                            .foregroundColor(Color(UIColor.systemRed))
                            .opacity(0.6)
                        RoundedRectangle(cornerSize: CGSize(width: 2, height: 4))
                            .size(width: (CGFloat(77) / 100.0) * metrics.size.width, height: 6)
                            .foregroundColor(Color(UIColor.white))
                    }
                    
                }
                HStack {
                    Label(String(entry.distanceDrivenKm) + " km", systemImage: "map")
                    Spacer()
                    Text("≈ n/a €")
                        .fontWeight(.bold)
                }
            }
        }
    }
}
