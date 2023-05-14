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
    
    var body: some View {
        NavigationStack {
            List {
                Section("14th May 2023") {
                    HistoryEntry()
                        .listRowSeparator(.hidden)
                }
            }
            .overlay(Group {
                if isLoading {
                    ProgressView()
                }
                })
                    .refreshable {
                        //self.loadSchedules()
                    }
                    .listStyle(.plain)
                    .navigationTitle("History")
            }
            //.onAppear(perform: self.loadSchedules)
            }
            }


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

struct HistoryEntry: View {
    var body: some View {
        GroupBox(label:
                    HStack {
            Label("07:45 - 08:01", systemImage: "steeringwheel")
            
            Spacer()
            
            Text("-20%")
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
                            .size(width: (CGFloat(40) / 100.0) * metrics.size.width, height: 6)
                            .foregroundColor(Color(UIColor.white))
                    }
                    
                }
                HStack {
                    Label("8 km", systemImage: "map")
                    Spacer()
                    Text("≈ 3,52 €")
                        .fontWeight(.bold)
                }
            }
        }
    }
}
