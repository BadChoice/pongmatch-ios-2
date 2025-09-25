//
//  LoginView.swift
//  pongmatch
//
//  Created by Jordi Puigdellívol on 7/9/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.openURL) private var openURL

    @State private var email:String = ""
    @State private var password:String = ""
    @State private var registering: Bool = false
    
    @State private var showScoreboard:Bool = false
    
    @FocusState private var focusedField: Field?
    private enum Field { case email, password }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 80)
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
            
            Spacer().frame(height: 60)
            
            // Email
            iconField(
                systemImage: "envelope.fill",
                tint: .accentColor
            ) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }
            }
            .padding(.horizontal)
            
            // Password
            iconField(
                systemImage: "lock.fill",
                tint: .accentColor
            ) {
                SecureField("Password", text: $password, prompt: Text("Password"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textContentType(.password)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        Task {
                            await auth.login(
                                email: email,
                                password: password,
                                deviceName: UIDevice.current.name
                            )
                        }
                    }
            }
            .padding(.horizontal)

            // Forgot password
            HStack {
                Spacer()
                Button {
                    openURL(Pongmatch.forgotPasswordUrl)
                } label: {
                    Text("Forgot password?")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .underline()
                }
                .padding(.trailing)
            }
                
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
                .background(Color.accentColor)
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
            
            Divider().padding(.bottom, 40)
            
            Button {
                showScoreboard.toggle()
            } label: {
                Label("Scoreboard", systemImage: "square.split.2x1")
                    .padding()
                    .foregroundStyle(.white)
                    .bold()
                    .glassEffect(.regular.tint(Color.accentColor).interactive())
            }
            
            Spacer()
        }
        .sheet(isPresented: $registering) {
            RegisterView()
                //.presentationDetents([.medium, .large]) // Bottom sheet style
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showScoreboard) {
            ScoreboardView(score: Score(game: Game.anonimus()))
        }
        .onAppear {
            focusedField = .email
        }
    }
}

private extension LoginView {
    @ViewBuilder
    func iconField<Content: View>(systemImage: String, tint: Color = .secondary, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint)
                .frame(width: 20, alignment: .leading)
                .font(.system(size: 16, weight: .regular)) // consistent symbol sizing
            Divider()
                .frame(height: 24)
                .overlay(Color.secondary.opacity(0.3))
            content()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
    }
}

#Preview {
    LoginView().environmentObject(
        AuthViewModel()
    )
}
