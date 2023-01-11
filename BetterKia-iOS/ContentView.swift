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

struct ExampleView: View {
    
    var body: some View {
        VStack {
            LottieView(lottieFile: "air-conditioner-and-heater-lottie")
                .frame(width: 300, height: 300)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ClimateControlScheduleView()
                .tabItem {
                    Label("Schedules", systemImage: "calendar")
                }
            ExampleView()
                .tabItem {
                    Label("Sent", systemImage: "tray.and.arrow.up.fill")
                }
            ExampleView()
                .badge("!")
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
