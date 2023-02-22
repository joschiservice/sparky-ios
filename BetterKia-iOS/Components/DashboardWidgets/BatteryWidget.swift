//
//  BatteryWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

struct BatteryWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        SimpleWidgetItem {
            VStack (spacing: 12) {
                Text(vehicleManager.vehicleData != nil ? "\(vehicleManager.vehicleData!.evStatus.batteryStatus)%" : "-")
                    .font(.system(size: 14))
                
                if (vehicleManager.vehicleData == nil) {
                    ZStack (alignment: .center) {
                        Image(systemName: "questionmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 12)
                            .zIndex(1)
                        Image(systemName: "battery.0")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                } else {
                    ZStack {
                        if (vehicleManager.vehicleData!.evStatus.batteryCharge) {
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                                .zIndex(1)
                        }
                        
                        if (vehicleManager.vehicleData!.evStatus.batteryStatus > 90) {
                            Image(systemName: "battery.100")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 60) {
                            Image(systemName: "battery.75")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 30) {
                            Image(systemName: "battery.50")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 19) {
                            Image(systemName: "battery.25")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        }
                        else {
                            Image(systemName: "battery.0")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Text("\(vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.evStatus.drvDistance.count > 0 ? "\(vehicleManager.vehicleData!.evStatus.drvDistance.first!.rangeByFuel.totalAvailableRange.value)" : "-") km")
                    .font(.system(size: 18, weight: .bold))
            }
        }
    }
}

struct BatteryWidgetPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
