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
    @State private var rotation: Double = 0
    
    private func startRotationAnimation() {
        var transaction = Transaction(animation: .linear(duration: 1.0).repeatForever(autoreverses: false))
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            rotation = 360
        }
    }
    
    private func stopRotationAnimation() {

        var transaction = Transaction(animation: .default)
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            rotation = 0
        }
    }
    
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
        label: {
            if (isBusy) {
                ProgressView()
            } else {
                Image(systemName: "fanblades.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(vehicleManager.isHvacActive ? .white : .gray)
                    .rotationEffect(.degrees(rotation))
                    .onChange(of: vehicleManager.isHvacActive) {
                        if vehicleManager.isHvacActive {
                            startRotationAnimation()
                        } else {
                            stopRotationAnimation()
                        }
                    }
                    .onAppear() {
                        if vehicleManager.isHvacActive {
                            startRotationAnimation()
                        }
                    }
            }
        }
        .frame(height: 20, alignment: .center)
        .frame(maxWidth: .infinity)
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
