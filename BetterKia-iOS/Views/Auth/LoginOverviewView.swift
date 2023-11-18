//
//  LoginView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 17.11.23.
//

import Foundation
import SwiftUI

struct LoginOverviewView : View {
    @State private var isShowingKiaLogin = false
    
    var body: some View {
        VStack {
            Text("Sign in to BetterKia")
                .font(.system(size: 34, weight: .bold))
                .padding()
            
            Spacer()
            
            VStack (spacing: 12) {
                Button {
                    isShowingKiaLogin = true;
                }
            label: {
                HStack {
                    Image("KiaLogoBlack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60)
                        .preferredColorScheme(.dark)
                    
                    Text("Sign in with Kia")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                }
            }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
                
                Button {
                }
            label: {
                HStack {
                    Label("", systemImage: "apple.logo")
                        .foregroundColor(.black)
                        .frame(width: 60)
                        .font(.system(size: 19))
                    
                    Text("Sign in with Apple")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                }
            }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(
             isPresented: $isShowingKiaLogin) {
                  SignInUsingKiaView()
             }
        .background(
                Image("LoginBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(x: -50, y: -5)
                    .ignoresSafeArea()
                    .opacity(0.6)
            )
    }
}
