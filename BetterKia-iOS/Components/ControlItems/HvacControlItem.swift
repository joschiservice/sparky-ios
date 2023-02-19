//
//  HvacControlItem.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

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
