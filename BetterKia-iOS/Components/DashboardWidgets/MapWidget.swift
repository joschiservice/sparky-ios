//
//  MapWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI
import MapKit

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
        updateMap();
    }
    
    func Setup() {
        _ = self.vehicleManager.$vehicleLocation.sink() {_ in
            updateMap();
        }
    }
    
    func updateMap() {
        if (vehicleManager.vehicleLocation == nil) {
            return;
        }
        
        let vehicleLocation = CLLocationCoordinate2D(latitude: vehicleManager.vehicleLocation!.latitude, longitude: vehicleManager.vehicleLocation!.longitude)
        
        self.region.center = vehicleLocation
        self.annotations.removeAll()
        
        self.annotations.append(CarPosition(name: "Car", coordinate: self.region.center))
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
                if (vehicleManager.isLoadingVehicleLocation) {
                    ProgressView()
                } else {
                    Text("Location not available")
                }
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

struct MapWidgetPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
