//
//  HvacControlItem.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

struct HvacControlItem: View {
    @ObservedObject var vehicleManager: VehicleManager
    @State var isBusy = false;
    
    var body: some View {
        Button {
            if (!vehicleManager.isHvacActive) {
                isBusy = true;
                Task {
                    _ = await vehicleManager.start();
                    isBusy = false;
                }
            } else {
                isBusy = true;
                Task {
                    _ = await vehicleManager.stop();
                    isBusy = false;
                }
            }
        }
    label:
        {
            if (isBusy) {
                ProgressView()
                    .frame(height: 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Image(systemName: "fanblades.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .foregroundColor(vehicleManager.isHvacActive ? .white : .gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .disabled(isBusy)
    }
}

struct HvacControlItemPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
