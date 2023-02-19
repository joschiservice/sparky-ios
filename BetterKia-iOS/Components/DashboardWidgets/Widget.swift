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
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(red: 40/255, green: 40/255, blue: 40/255))
            )
        }
    }
}
