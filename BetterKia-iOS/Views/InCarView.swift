//
//  InCarView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 02.09.23.
//

import Foundation
import SwiftUI
import ColorPickerRing

func createColor(r: Int, g: Int, b: Int) -> Color {
    return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
}

struct InCarView: View {
    @State private var color = UIColor.red
    
    var body: some View {
        NavigationStack {
            VStack {
                AmbientLightThemeButton(text: "Chill Blue", color: createColor(r: 4, g: 92, b: 207))
                AmbientLightThemeButton(text: "Performance Red", color: createColor(r: 173, g: 21, b: 21))
                NavigationLink("Custom color") {
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color(color))
                            .frame(height: 100)
                        Spacer()
                        ColorPickerRing(color: $color, strokeWidth: 30)
                                    .frame(width: 300, height: 300, alignment: .center)
                        Spacer()
                    }
                }
                .padding(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
            }
            .navigationTitle("In Car UI")
        }
    }
}


struct InCarView_Previews: PreviewProvider {
    static var previews: some View {
        InCarView()
    }
}

struct AmbientLightThemeButton: View {
    func onClick() -> Void {
        
    }
    
    var text: String
    var color: Color
    
    var body: some View {
        Button (action: onClick) {
            ZStack {
                Rectangle()
                    .fill(color)
                    .frame(height: 100)
                
                Text(text)
                    .foregroundColor(.white)
            }
        }
    }
}
