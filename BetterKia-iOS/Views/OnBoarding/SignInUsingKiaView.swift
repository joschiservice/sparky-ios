//
//  SignInUsingKiaView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 08.03.23.
//

import Foundation
import SwiftUI

struct SignInUsingKiaView : View {
    @State private var kiaEmail: String = ""
    @State private var kiaPassword: String = ""
    @State private var isAuthenticating: Bool = false
    
    func login() {
        isAuthenticating = true
        
        if (kiaEmail == "") {
            AlertManager.shared.publishAlert("Kia Connect Email cannot be empty", description: "Please fill in your Kia Connect email address to sign in.")
            return;
        }
        
        if (kiaPassword == "") {
            AlertManager.shared.publishAlert("Kia Connect Password cannot be empty", description: "Please fill in your Kia Connect password to sign in.")
        }
        
        Task {
            await AuthManager.shared.authenticateUsingKia(email: kiaEmail, password: kiaPassword)
        }
    }
    
    var body: some View {
        VStack {
            Text("Sign in to BetterKia")
                .font(.system(size: 34, weight: .bold))
                .padding()
            
            VStack {
                Text("Kia Connect Email")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                TextField("Email", text: $kiaEmail)
                    .keyboardType(.emailAddress)
                    .scrollDismissesKeyboard(.interactively)
                    .autocorrectionDisabled(true)
                    .textContentType(.emailAddress)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            
            VStack {
                Text("Kia Connect Password")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                SecureField("Password", text: $kiaPassword)
                    .scrollDismissesKeyboard(.interactively)
                    .textContentType(.password)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            
            VStack {
                Button {
                    login()
                }
            label: {
                if (!isAuthenticating) {
                    Text("Sign In")
                        .font(.system(size: 20))
                            .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
                .padding()
                .disabled(isAuthenticating)
                .background(Color(red: 30/256, green: 30/256, blue: 30/256))
                .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            
            Text("Note: We won't store your Kia Connect password at any times. We will just use it in the login process to validate your identity on this device.")
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                .font(.system(size: 16))
                .opacity(0.6)
                .frame(alignment: .leading)
            
            Spacer()
        }
        .padding()
    }
}

struct SignInUsingKiaView_Previews: PreviewProvider {
    static var previews: some View {
        SignInUsingKiaView()
    }
}
