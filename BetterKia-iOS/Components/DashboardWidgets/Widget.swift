//
//  Widget.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import SwiftUI

struct SimpleWidgetItem<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center, content: content)
                .frame(maxWidth: .infinity, maxHeight: 130, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .foregroundColor(Color(red: 40/255, green: 40/255, blue: 40/255))
                    .shadow(color: Color(red: 30/255, green: 30/255, blue: 30/255), radius: 6)
                    
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(red: 100/255, green: 100/255, blue: 100/255), lineWidth: 0.5)
            )
        }
    }
}
