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

struct ControlItem: View {
    let iconName: String
    
    var body: some View {
        Button {
            
        }
    label:
        {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct HvacControlItem: View {
    @ObservedObject var vehicleManager: VehicleManager
    @State var isActivatingHvac = false;
    
    var body: some View {
        Button {
            if (!vehicleManager.isHvacActive) {
                isActivatingHvac = true;
                Task {
                    _ = await vehicleManager.start();
                    isActivatingHvac = false;
                }
            }
        }
    label:
        {
            if (isActivatingHvac) {
                ProgressView()
            } else {
                Image(systemName: "fanblades.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .foregroundColor(vehicleManager.isHvacActive ? .white : .gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .disabled(isActivatingHvac)
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

struct BatteryWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        SimpleWidgetItem {
            Text(vehicleManager.vehicleData != nil ? "\(vehicleManager.vehicleData!.evStatus.batteryStatus)%" : "-")
                .font(.system(size: 14))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            
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
            } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 90) {
                Image(systemName: "battery.100")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 60) {
                Image(systemName: "battery.75")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 25) {
                Image(systemName: "battery.50")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            } else if (vehicleManager.vehicleData!.evStatus.batteryStatus > 15) {
                Image(systemName: "battery.25")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            else {
                Image(systemName: "battery.0")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }
            
            Text("\(vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.evStatus.drvDistance.count > 0 ? "\(vehicleManager.vehicleData!.evStatus.drvDistance.first!.rangeByFuel.totalAvailableRange.value)" : "-") km")
                .font(.system(size: 18, weight: .bold))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct HvacWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        SimpleWidgetItem {
            Button {
                
            }
        label: {
            Image(systemName: "chevron.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 14)
                .foregroundColor(.red)
            
        }
            
            HStack {
                Image(systemName: "heater.vertical.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor((vehicleManager.vehicleData?.acc ?? false) ? .white : .gray)
                    .frame(height: 26)
                Text("\(vehicleManager.currentHvacTargetTemp != nil ? "\( vehicleManager.currentHvacTargetTemp!)°" : "-")")
                    .font(.system(size: 24))
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            
            Button {
                
            }
        label: {
            Image(systemName: "chevron.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 14)
                .foregroundColor(.blue)
        }
        }
    }
}

struct HvacOptionsWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    var body: some View {
        SimpleWidgetItem {
            VStack {
                HStack (alignment: .center, spacing: 16) {
                    Image(systemName: "windshield.front.and.heat.waves")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor((vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.defrost) ? .white : .gray)
                    
                    Image(systemName: "windshield.rear.and.heat.waves")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor((vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.sideBackWindowHeat > 0) ? .white : .gray)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                HStack (alignment: .center, spacing: 16) {
                    Image(systemName: "steeringwheel.and.heat.waves")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor((vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.steerWheelHeat > 0) ? .red : .gray)
                    
                    Image(systemName: "mirror.side.left.and.heat.waves")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor((vehicleManager.vehicleData != nil && vehicleManager.vehicleData!.sideBackWindowHeat > 0) ? .white : .gray)
                }
            }
            .padding()
        }
    }
}

struct VehicleStatusInfoWidget: View {
    var body: some View {
        SimpleWidgetItem {
            VStack {
                Text("Vehicle Status")
                    .font(.system(size: 10, weight: .bold))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                
                Image(systemName: "parkingsign.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding()
        }
    }
}

struct CarPosition: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct MapWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    init(vehicleManager: VehicleManager) {
        self.vehicleManager = vehicleManager
        self.Setup()
    }
    
    func Setup() {
        _ = self.vehicleManager.$vehicleLocation.sink() {
            if ($0 == nil) {return;}
            let vehicleLocation = CLLocationCoordinate2D(latitude: $0!.latitude, longitude: $0!.longitude)
            
            self.region.center = vehicleLocation
            self.annotations.removeAll()
            
            self.annotations.append(CarPosition(name: "Car", coordinate: self.region.center))
        }
    }
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 54.19478906001295, longitude: 9.093066782003024), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
    
    @State private var annotations: [CarPosition] = []
    
    var body: some View {
        SimpleWidgetItem {
            if (!annotations.isEmpty) {
                Map(coordinateRegion: $region, interactionModes: .all, annotationItems: annotations) {
                    MapAnnotation(coordinate: $0.coordinate) {
                        VStack (alignment: .center) {
                            Image(systemName: "car.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 12)
                        }
                        .background(Circle()
                            .foregroundColor(.blue)
                            .frame(width: 28, height: 28))
                    }
                }
                    .frame(height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Text("Location not available")
            }
        }
        .onAppear {
            MKMapView.appearance().isZoomEnabled = false;
            MKMapView.appearance().isScrollEnabled = false;
            MKMapView.appearance().isPitchEnabled = false;
            MKMapView.appearance().isRotateEnabled = false;
            
        }
    }
}

struct SimpleWidgetItem<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center, content: content)
                .frame(maxWidth: .infinity, maxHeight: 130, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(red: 40/255, green: 40/255, blue: 40/255))
            )
        }
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
