//
//  HvacWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

struct HvacWidget: View {
    @ObservedObject var vehicleManager: VehicleManager
    
    @State var currentTargetTemp: Double = ConfigManager.shared.hvacTargetTemp
    
    private let HVAC_MIN_TEMP = 17.0;
    private let HVAC_MAX_TEMP = 27.0;
    private let HVAC_TEMP_STEP = 0.5;
    
    private func increaseHvacTemp() {
        currentTargetTemp += HVAC_TEMP_STEP
        ConfigManager.shared.hvacTargetTemp = currentTargetTemp
    }
    
    private func decreaseHvacTemp() {
        currentTargetTemp -= HVAC_TEMP_STEP
        ConfigManager.shared.hvacTargetTemp = currentTargetTemp
    }
    
    var body: some View {
        SimpleWidgetItem {
            Button {
                increaseHvacTemp()
            }
        label: {
            Image(systemName: "chevron.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 14)
                .foregroundColor(currentTargetTemp == HVAC_MAX_TEMP ? .gray  : .red)
            
        }
        .disabled(currentTargetTemp == HVAC_MAX_TEMP)
            
            HStack {
                Text("\("\(currentTargetTemp)°")")
                    .font(.system(size: 28))
            }
            .padding(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 0))
            
            Button {
                decreaseHvacTemp()
            }
        label: {
            Image(systemName: "chevron.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 14)
                .foregroundColor(currentTargetTemp == HVAC_MIN_TEMP ? .gray : .blue)
        }
        .disabled(currentTargetTemp == HVAC_MIN_TEMP)
            
        }
    }
}

struct HvacWidgetPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
