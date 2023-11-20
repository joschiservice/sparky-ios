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
    @State private var isShowingDetailView = false
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var vehicleManager = IS_DEMO_MODE ? VehicleManager.getPreviewInstance() : VehicleManager.shared // ToDo: I don't like this here
    
    let checkVehicleDataAgeTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    /**
     This function ensure, that the vehicle data is not outdated. It will refresh the data, if it exceeded the maximum age.
     */
    func ensureVehicleDataAge(newScenePhase: ScenePhase? = nil) {
        if IS_DEMO_MODE {
            return;
        }
        
        // Ensure that app is in foreground, as we don't want any expensive and unecessary background updates
        let currentScenePhase = newScenePhase ?? scenePhase;
        if currentScenePhase != .active {
            return;
        }
        
        // Get elapsed time since last update
        if vehicleManager.lastVehicleDataUpdate != nil {
            let elapsedTime = Calendar.current.dateComponents([.minute], from: vehicleManager.lastVehicleDataUpdate!, to: Date());
            
            print("DashboardView::ensureVehicleDataAge: \(elapsedTime.minute ?? 0) minutes have been elapsed since the last vehicle data update");
            
            if elapsedTime.minute ?? 0 < MAX_VEHICLE_DATA_AGE {
                return;
            }
        }
        
        // No duplicates
        if vehicleManager.vehicleDataStatus == .Refreshing {
            return;
        }
        
        print("DashboardView::ensureVehicleDataAge: Refreshing data")
        
        Task {
            await vehicleManager.getVehicleData();
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack (alignment: .center) {
                    Image("KiaLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                    
                    Text("Kia e-Soul Spirit")
                        .foregroundColor(.gray)
                }
                
                VStack {
                    switch (vehicleManager.vehicleDataStatus) {
                    case VehicleDataStatus.Refreshing:
                        ProgressView()
                    case .UnknownError:
                        Button {
                            AlertManager.shared.publishAlert("No vehicle data available", description: "An unknown error occured while retrieving your vehicle data.")
                        }
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    case .Success:
                        Button {
                            let formatter = DateFormatter();
                            formatter.timeStyle = .short;
                            let lastUpdateTimeText = formatter.string(from: vehicleManager.lastVehicleDataUpdate!);
                            let dataAgeText = formatter.string(from: vehicleManager.vehicleData!.time);
                            AlertManager.shared.publishAlert("Vehicle data is up-to-date!", description: "Everything is fine! The last update was at \(lastUpdateTimeText) and the data was received from the car at \(dataAgeText)")
                        }
                    label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    case .RateLimitedByOEM:
                        Button {
                            AlertManager.shared.publishAlert("No vehicle data available for today", description: "Oh no! The manufacturer of your vehicle doesn't allow us to make more data requests for the rest of the day. Please wait until the next day.")
                        }
                    label: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                    }
                }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
            }
            
            if (vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.evStatus.batteryCharge) {
                Image("KiaSoulCharging")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 0, y: 0)
                    .frame(height: 200)
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0))
            } else {
                Image("KiaSoul")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(x: 50, y: 0)
                    .frame(height: 200)
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0))
            }
            
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
        .onAppear {
            if (IS_DEMO_MODE) {
                return;
            }
            
            if (vehicleManager.vehicleData == nil) {
                Task {
                    await vehicleManager.getVehicleData()
                    await vehicleManager.getVehicleLocation()
                }
            }
        }
        .onReceive(checkVehicleDataAgeTimer) { _ in
            ensureVehicleDataAge()
        }
        .onChange(of: scenePhase) { newScenePhase in
            ensureVehicleDataAge(newScenePhase: newScenePhase)
        }
    }
}

struct ControlItems: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        Grid {
            GridRow {
                LockControlItem(vehicleManager: vehicleManager)
                HvacControlItem(vehicleManager: vehicleManager)
                ControlItem(iconName: "bolt.fill")
                RefreshControlItem(vehicleManager: vehicleManager)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
    }
}

struct DashboardViewPreviews: PreviewProvider {
    static func getPreviewVmanager() -> VehicleManager {
        return VehicleManager.getPreviewInstance()
    }
    
    static var previews: some View {
        DashboardView(vehicleManager: getPreviewVmanager())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        ControlItems(vehicleManager: getPreviewVmanager())
            .previewDisplayName("Dashboard: Control Items")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
