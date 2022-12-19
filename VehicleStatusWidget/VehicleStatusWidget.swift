//
//  VehicleStatusWidget.swift
//  VehicleStatusWidget
//
//  Created by Joschua Haß on 19.12.22.
//

import WidgetKit
import SwiftUI
import Intents
import os

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), batPercentage: 0, remainingDistance: "0")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entry = SimpleEntry(date: Date(), batPercentage: 0, remainingDistance: "-")
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let logger = Logger()
        
        logger.log("next update: \(DateFormatter().string(from: nextUpdateDate))")
        
        let url = URL(string: "https://better-kia.vcc-online.eu/api/hello")!
        
        var request = URLRequest(url: url)
        
        let auth = Data("2384z27834687236478f67826482|fjfiuwergisidjb4r734fsj3".utf8).base64EncodedString()
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data, let vehicleStatusData = try? JSONDecoder().decode(VehicleStatusResponse.self, from: data) {
                let evStatus = vehicleStatusData.vehicleStatus.evStatus
                
                entry.batPercentage = evStatus.batteryStatus
                entry.remainingDistance = String(evStatus.drvDistance.first?.rangeByFuel.totalAvailableRange.value ?? 0)
            } else {
                // error
            }
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
        
        task.resume()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), batPercentage: 0, remainingDistance: "0")
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    var batPercentage: Int
    var remainingDistance: String
    
    func getTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:MM"
        
        return formatter.string(from: date)
    }
}

struct VehicleStatusWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack (spacing: 0) {
            HStack(spacing: 1) {
                Text(String(entry.batPercentage))
                    .font(.title)
                Text("%")
                    .font(.title)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .frame(width: 138, height: 15)
                    .foregroundColor(Color(UIColor.systemGray6))
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .size(width: CGFloat((Float(entry.batPercentage) / 100.0) * 138), height: 15)
                    .frame(width: .infinity, height: 15)
                    .foregroundColor(Color(UIColor.systemGreen))
            }
            HStack(spacing: 1) {
                Text("PARKED")
                    .font(.footnote)
                    .fontWeight(.bold)
                Text(" | \(entry.remainingDistance) km")
                    .font(.footnote)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 2, bottom: 0, trailing: 0))
            Image("eSoulIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
            
            HStack(spacing: 1) {
                Text(entry.getTimeString())
                    .font(.system(size: 12))
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .padding()
    }
}

struct VehicleStatusWidget: Widget {
    let kind: String = "VehicleStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VehicleStatusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vehicle Status Widget")
        .description("Displays the current status of your vehicle")
        .supportedFamilies([.systemSmall])
    }
}

struct VehicleStatusWidget_Previews: PreviewProvider {
    static var previews: some View {
        VehicleStatusWidgetEntryView(entry: SimpleEntry(date: Date(), batPercentage: 64, remainingDistance: "230"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
