//
//  HvacOptionsWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

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
