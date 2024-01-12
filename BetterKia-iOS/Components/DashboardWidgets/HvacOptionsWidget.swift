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
                    HvacOptionItem(iconName: "windshield.front.and.heat.waves", hvacOption: vehicleManager.frontWindshieldHvacOption)
                    
                    HvacOptionItem(iconName: "windshield.rear.and.heat.waves", hvacOption: vehicleManager.heatedFeaturesHvacOption)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                HStack (alignment: .center, spacing: 16) {
                    HvacOptionItem(iconName: "steeringwheel.and.heat.waves", hvacOption: vehicleManager.heatedFeaturesHvacOption)
                    
                    HvacOptionItem(iconName: "mirror.side.left.and.heat.waves", hvacOption: vehicleManager.heatedFeaturesHvacOption)
                }
            }
            .padding()
        }
    }
}

struct HvacOptionItem: View {
    public let iconName: String
    @StateObject public var hvacOption: HvacOption
    
    var body: some View {
        Button {
            hvacOption.state = hvacOption.state == HvacOptionState.Off ? HvacOptionState.Selected : HvacOptionState.Off
        }
    label: {
        Image(systemName: iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(hvacOption.state == HvacOptionState.Active ? .red : hvacOption.state == HvacOptionState.Selected ? .white : .gray)
    }
    }
}

struct HvacOptionsWidgetPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView(vehicleManager: VehicleManager.getPreviewInstance())
            .previewDisplayName("Dashboard: Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        DashboardView()
            .previewDisplayName("Dashboard: No Data")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
