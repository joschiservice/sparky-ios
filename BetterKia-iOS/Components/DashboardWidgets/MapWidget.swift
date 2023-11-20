//
//  MapWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI
import MapKit

struct MapWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
        
    var body: some View {
        SimpleWidgetItem {
            if (vehicleManager.vehicleLocation != nil) {
                Map(coordinateRegion: $vehicleManager.vehicleRegion, interactionModes: .all, annotationItems: vehicleManager.vehiclePositionAnnotations ) {
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
                    VStack {
                        Text("Location not available")
                        Button("Learn more") {
                            AlertManager.shared.publishAlert("Info: Location not available", description: "During the development of this app, we noticed that requesting the latest (not current) vehicle location from Kia's servers takes 11 seconds. Due to the current plan of our own servers, request can't be longer than 10 seconds. There's a very high probability this issue does also affect you. We will upgrade our server plan as soon as it's possible for us.")
                        }
                    }
                    
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
