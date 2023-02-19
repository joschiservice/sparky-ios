//
//  HvacWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

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
