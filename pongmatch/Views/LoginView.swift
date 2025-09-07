//
//  LoginView.swift
//  pongmatch
//
//  Created by Jordi Puigdellívol on 7/9/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: AuthViewModel

    
    // Input
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var deviceName:String = (UIDevice.current.name)
    @State private var showPassword:Bool = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            
            SecureField("Password", text: $password, prompt: Text("Password"))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
                .textContentType(.password)
                
                .submitLabel(.done)
                
            Button {
                Task {
                    await session.login(email: email, password: password, deviceName: deviceName)
                }
            } label: {
                HStack {
                    if session.isLoading { ProgressView().tint(.white) }
                    Text(session.isLoading ? "Signing In..." : "Login")
                }
            }
            .disabled(session.isLoading || email.isEmpty || password.isEmpty)
            .padding()
            .background(.black)
            .cornerRadius(8)
            .foregroundColor(.white)
            
        }
    }
    
    private func login() async throws {
        let token = try await Api.login(email: email, password: password, deviceName: deviceName)
        Storage().save(.apiToken, value: token)
    }
}

#Preview {
    LoginView().environmentObject(
        AuthViewModel()
    )
}
