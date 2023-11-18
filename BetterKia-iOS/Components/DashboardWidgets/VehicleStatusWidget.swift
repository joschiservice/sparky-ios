//
//  VehicleStatusWidget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

struct VehicleStatusInfoWidget: View {
    var body: some View {
        SimpleWidgetItem {
            VStack {
                Image(systemName: "parkingsign.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                
                Text("Parked")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding()
        }
    }
}
