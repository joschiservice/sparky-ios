//
//  LockControlItem.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

struct LockControlItem: View {
    @ObservedObject var vehicleManager: VehicleManager
    @State var isBusy = false;
    
    var body: some View {
        Button {
            if (vehicleManager.isVehicleLocked) {
                isBusy = true;
                Task {
                    await vehicleManager.unlock();
                    isBusy = false;
                }
            } else {
                isBusy = true;
                Task {
                    await vehicleManager.lock();
                    isBusy = false;
                }
            }
        }
    label:
        {
            if (isBusy) {
                ProgressView()
            } else {
                if (vehicleManager.isVehicleLocked) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Image(systemName: "lock.open.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .disabled(isBusy)
    }
}

struct LockControlItemPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}

