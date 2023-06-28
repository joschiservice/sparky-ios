//
//  ContentView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 18.12.22.
//

import SwiftUI
import os
import WidgetKit
import ActivityKit
import Lottie
import Combine
 
struct LottieView: UIViewRepresentable {
    let lottieFile: String
 
    let animationView = LottieAnimationView()
 
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
 
        animationView.animation = LottieAnimation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
 
        view.addSubview(animationView)
 
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
 
        return view
    }
 
    func updateUIView(_ uiView: UIViewType, context: Context) {
 
    }
}

struct AccountView: View {
    
    var body: some View {
        VStack {
            Text("Account View")
        }
    }
}

struct ContentView: View {
    @ObservedObject private var vehicleManager = VehicleManager.shared
    @ObservedObject private var alertManager = AlertManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        if authManager.isAuthenticated == true {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "bolt.car.fill")
                    }
                ClimateControlScheduleView()
                    .tabItem {
                        Label("Schedules", systemImage: "clock")
                    }
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "calendar")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .sheet(isPresented: $vehicleManager.showClimateControlPopover) {
                StartInfoView()
            }
            .alert(alertManager.currentAlertTitle, isPresented: $alertManager.showAlert, actions: {
                
            }, message: {
                Text(alertManager.currentAlertDescription)
            })
            .onAppear {
                Task {
                    VehicleManager.shared.loadCachedVehicleStatus();
                }
                
                Task {
                    _ = await VehicleManager.shared.getPrimaryVehicle();
                }
            }
        } else {
            OnBoardingView()
                .alert(alertManager.currentAlertTitle, isPresented: $alertManager.showAlert, actions: {
                    
                }, message: {
                    Text(alertManager.currentAlertDescription)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "bolt.car.fill")
                }
            ClimateControlScheduleView()
                .tabItem {
                    Label("Schedules", systemImage: "clock")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .previewDisplayName("Authenticated")
        
    }
}
