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
                Text("Vehicle Status")
                    .font(.system(size: 10, weight: .bold))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                
                Image(systemName: "parkingsign.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding()
        }
    }
}
