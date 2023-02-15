//
//  OnBoardingView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.02.23.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct OnBoardingView: View {
    @State private var animateGradient = false
    @State private var isShowingDetailView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView {
                    GeneralInfo()
                    Text("Second")
                    Text("Third")
                    Text("Fourth")
                        }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                HStack {
                    Button {
                        isShowingDetailView = true
                    }
                label: {
                    Text("Continue")
                        .font(.system(size: 20))
                            .frame(maxWidth: .infinity)
                }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                }
                .padding()
            }
            .background(
                LinearGradient(colors: [.blue, .init(red: 187/255, green: 22/255, blue: 44/255)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .hueRotation(.degrees(animateGradient ? 25 : 0))
                    .ignoresSafeArea()
                    .onAppear {
                            withAnimation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true)) {
                                animateGradient.toggle()
                            }
                        }
            )
            .preferredColorScheme(.dark)
            .navigationDestination(
                 isPresented: $isShowingDetailView) {
                      LoginView()
                 }
        }
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView()
        LoginView()
    }
}

struct GeneralInfo : View {
    
    var body: some View {
        VStack {
            Text("Welcome to BetterKia, your daily assistant for your Kia.")
                .font(.system(size: 34, weight: .bold))
                .padding()
            
            Spacer()
            
            HStack {
                Image("KiaLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                
                Label("", systemImage: "wave.3.left")
                    .font(.system(size: 30))
                
                Label("", systemImage: "iphone.rear.camera")
                    .font(.system(size: 30))
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
    }
}

struct LoginView : View {
    var body: some View {
        VStack {
            Text("Sign in to BetterKia")
                .font(.system(size: 34, weight: .bold))
                .padding()
            
            Spacer()
            
            VStack (spacing: 12) {
                Button {
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
