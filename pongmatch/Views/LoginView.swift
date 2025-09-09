//
//  LoginView.swift
//  pongmatch
//
//  Created by Jordi Puigdellívol on 7/9/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel

    @State private var email:String = ""
    @State private var password:String = ""
    
    var body: some View {
        VStack {
            
            Image("logo")
            
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
                    await auth.login(
                        email: email,
                        password: password,
                        deviceName: UIDevice.current.name
                    )
                }
            } label: {
                HStack {
                    if auth.isLoading { ProgressView().tint(.white) }
                    Text(auth.isLoading ? "" : "Login")
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(.black)
                .clipShape(.capsule)
                .foregroundStyle(.white)
            }
            .disabled(auth.isLoading || email.isEmpty || password.isEmpty)
        }
    }
}

#Preview {
    LoginView().environmentObject(
        AuthViewModel()
    )
}
