//
//  VehicleStatusWidgetLiveActivity.swift
//  VehicleStatusWidget
//
//  Created by Joschua Haß on 19.12.22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveChargeStatusWidgetAttributes: ActivityAttributes {
    public typealias ChargeStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var batteryCharge: Int
        var minRemaining: Int
        var chargeLimit: Int
        var chargedKw: Int
    }
}

struct VehicleStatusWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveChargeStatusWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    VStack () {
                        Image("KiaIconWhite")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(EdgeInsets(top: 0, leading: -40, bottom: 0, trailing: 0))
                        HStack {
                            Image(systemName: "battery.100.bolt")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.green)
                            Text("\(context.state.batteryCharge)%")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                        }
                            
                    }
                    Spacer()
                    VStack {
                        Text("Time Remaining")
                            .opacity(0.8)
                            .font(.caption)
                        Text("\(context.state.minRemaining) min")
                    }
                }
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .frame(width: .infinity, height: 16, alignment: .leading)
                            .foregroundColor(Color(UIColor.systemGray6))
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .size(width: geometry.size.width * (CGFloat(context.state.batteryCharge) / 100), height: 16)
                            .frame(width: .infinity, height: 16, alignment: .leading)
                            .foregroundColor(Color(UIColor.systemGreen))
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24, alignment: .center)
                            .shadow(radius: 5)
                    }
                }
                Text("Charge Limit: \(context.state.chargeLimit)%  •  ≈ \(context.state.chargedKw)kw")
                    .font(.caption)
                    .opacity(0.8)
                    .padding(EdgeInsets(top: 14, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(width: .infinity)
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct VehicleStatusWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = LiveChargeStatusWidgetAttributes()
    static let contentState = LiveChargeStatusWidgetAttributes.ContentState(batteryCharge: 70, minRemaining: 8, chargeLimit: 80, chargedKw: 28)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
