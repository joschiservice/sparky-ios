//
//  ContentView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 18.12.22.
//

import SwiftUI
import os
import WidgetKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
            Button("Helo") {
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                
                let formatter = DateFormatter()
                
                formatter.dateFormat = "HH:mm"
                
                Logger().log("\(formatter.string(from: nextUpdateDate))")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
