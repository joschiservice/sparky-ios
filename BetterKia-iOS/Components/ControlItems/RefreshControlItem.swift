//
//  RefreshControlItem.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 20.02.23.
//

import SwiftUI

struct RefreshControlItem: View {
    @ObservedObject var vehicleManager: VehicleManager
    @State var isBusy = false;
    
    var body: some View {
        Button {
            isBusy = true;
            Task {
                _ = await vehicleManager.getVehicleData(forceRefresh: true);
                isBusy = false;
            }
        }
    label:
        {
            if (isBusy) {
                ProgressView()
                    .frame(height: 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .disabled(isBusy)
    }
}

struct RefreshControlItemPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}

