//
//  DashboardView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 16.02.23.
//

import Foundation
import SwiftUI
import MapKit

struct DashboardView: View {
    @State private var animateGradient = false
    @State private var isShowingDetailView = false
    @ObservedObject var vehicleManager = VehicleManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("KiaLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                    
                    Text("Kia e-Soul Spirit")
                        .foregroundColor(.gray)
                }
                
                Image("KiaSoul")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(x: 50, y: 0)
                    .frame(height: 200)
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0))
                
                ControlItems(vehicleManager: vehicleManager)
                
                Grid (horizontalSpacing: 14, verticalSpacing: 14) {
                    GridRow (alignment: .center) {
                        BatteryWidget(vehicleManager: vehicleManager)
                        MapWidget(vehicleManager: vehicleManager)
                            .gridCellColumns(2)
                    }
                    
                    GridRow (alignment: .center) {
                        HvacWidget(vehicleManager: vehicleManager)
                        HvacOptionsWidget(vehicleManager: vehicleManager)
                        VehicleStatusInfoWidget()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1") {
                return;
            }
            
            if (vehicleManager.vehicleData == nil) {
                Task {
                    await vehicleManager.getVehicleData()
                }
            }
            if (vehicleManager.vehicleLocation == nil) {
                Task {
                    await vehicleManager.getVehicleLocation()
                }
            }
        }
    }
}

struct ControlItems: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        Grid {
            GridRow {
                ControlItem(iconName: "lock.fill")
                HvacControlItem(vehicleManager: vehicleManager)
                ControlItem(iconName: "bolt.fill")
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
    }
}

struct DashboardViewPreviews: PreviewProvider {
    static func getPreviewVmanager() -> VehicleManager {
        let vmanager = VehicleManager()
        vmanager.currentHvacTargetTemp = 22
        vmanager.vehicleData = VehicleStatus(
            evStatus: EvStatus(batteryCharge: true, batteryStatus: 20, drvDistance: [DriveDistance(rangeByFuel: RangeByFuel(totalAvailableRange: RangeData(value: 320, unit: 1)))]),
            time: "2022-03-01", acc: true, sideBackWindowHeat: 1, steerWheelHeat: 1, defrost: true)
        vmanager.vehicleLocation = VehicleLocation(latitude: 54.19478906001295, longitude: 9.093066782003024, speed: VehicleSpeed(unit: 0, value: 0), heading: 0);
        vmanager.isHvacActive = true;
        return vmanager
    }
    
    static var previews: some View {
        DashboardView(vehicleManager: getPreviewVmanager())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
