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
    @State private var registering: Bool = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 80)
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
            
            
            Spacer().frame(height: 60)
            
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
                .bold()
                .padding()
            }
            .disabled(auth.isLoading || email.isEmpty || password.isEmpty)
            
            if auth.errorMessage != nil {
                Text(auth.errorMessage!)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            
            Button("Sign Up") {
                registering = true
            }

            Spacer().frame(height: 40)
            NavigationLink("Scoreboard"){
                ScoreboardView(score: Score(game: Game.anonimus()))
            }
            
            Spacer()
        }.sheet(isPresented: $registering) {
            RegisterView()
                //.presentationDetents([.medium, .large]) // Bottom sheet style
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    LoginView().environmentObject(
        AuthViewModel()
    )
}
