//
//  DashboardView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 16.02.23.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @State private var animateGradient = false
    @State private var isShowingDetailView = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("KiaLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                    
                    Text("Kia e-Soul Spirit")
                        .foregroundColor(.gray)
                }
                
                Image("KiaSoul")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(x: 0, y: 0)
                    .frame(height: 300)
                
                Grid (horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow (alignment: .center) {
                        BatteryWidget()
                        BatteryWidget()
                            .gridCellColumns(2)
                    }
                    
                    GridRow (alignment: .center) {
                        BatteryWidget()
                        BatteryWidget()
                        BatteryWidget()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct BatteryWidget: View {
    var body: some View {
        SimpleWidgetItem {
            Text("70%")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            
            Label("", systemImage: "battery.100")
                .font(.system(size: 40))
                .foregroundColor(.green)
            
            Text("300 km")
                .font(.system(size: 18, weight: .bold))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct SimpleWidgetItem<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center, content: content)
            .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(red: 40/255, green: 40/255, blue: 40/255))
            )
        }
    }
}

struct DashboardViewPreviews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
