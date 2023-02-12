//
//  StartInfo.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 12.02.23.
//

import Foundation
import SwiftUI

struct StartInfoView: View {
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading) {
                Text("Starting\nair conditioning...")
                    .fontWeight(.bold)
                    .font(.system(size: 40))
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                Spacer()
                LottieView(lottieFile: "air-conditioner-and-heater-lottie")
                    .frame(width: 300, height: 150)
                Spacer()
            }
            .padding()
        }
    }
}

struct StartInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StartInfoView()
    }
}
