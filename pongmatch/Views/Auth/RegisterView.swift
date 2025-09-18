import SwiftUI
//import AuthenticationServices

struct RegisterView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    @State var name: String = ""
    @State var username: String = ""
        
    @FocusState private var isNameFocused: Bool

    
    // Validation properties
    var isEmailValid: Bool {
        let emailRegex = #"^\S+@\S+\.\S+$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    var isPasswordConfirmed: Bool {
        password == passwordConfirmation && !password.isEmpty
    }
    
    var isUsernameValid: Bool {
        username.count > 3 && !username.contains(" ")
    }
    
    var isNameValid: Bool {
        name.count >= 3
    }
    
    var isFormValid: Bool {
        isEmailValid && isPasswordConfirmed && isUsernameValid && isNameValid
    }
    
    var body: some View {
        ScrollView{
            VStack {
                
                Spacer().frame(height: 60)
                
                VStack{
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    
                    Spacer().frame(height: 20)
                    
                    Text("Join Pongmatch and connect with players near you!")
                    Text("Create your account to start challenging, tracking your games, and making new friends.")
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    Spacer().frame(height: 20)
                    
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                
                // Name
                iconField(
                    systemImage: "person.fill",
                    tint: .secondary,
                    content: {
                        TextField("Name", text: $name)
                            .focused($isNameFocused)
                            .textContentType(.name)
                            .submitLabel(.next)
                    }
                )
                .padding(.horizontal)
                
                if !isNameValid && !name.isEmpty {
                    Text("Name must be at least 3 characters.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Username
                iconField(
                    systemImage: "at",
                    tint: .secondary,
                    content: {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textContentType(.username)
                            .submitLabel(.next)
                    }
                )
                .padding(.horizontal)
                
                if !isUsernameValid && !username.isEmpty {
                    Text("Username must be >3 characters and have no spaces.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Email
                iconField(
                    systemImage: "envelope.fill",
                    tint: .secondary,
                    content: {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .textContentType(.emailAddress)
                            .submitLabel(.next)
                    }
                )
                .padding(.horizontal)
                
                if !isEmailValid && !email.isEmpty {
                    Text("Enter a valid email address.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Divider().padding(.vertical)
                
                // Password
                iconField(
                    systemImage: "lock.fill",
                    tint: .secondary,
                    content: {
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                    }
                )
                .padding(.horizontal)
                
                // Password Confirmation
                iconField(
                    systemImage: "lock.rotation.open",
                    tint: .secondary,
                    content: {
                        SecureField("Password Confirmation", text: $passwordConfirmation)
                            .textContentType(.newPassword)
                            .submitLabel(.done)
                    }
                )
                .padding(.horizontal)
                
                if !isPasswordConfirmed && !passwordConfirmation.isEmpty {
                    Text("Passwords do not match.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button {
                    Task {
                        await auth.register(
                            name:name,
                            username:username.lowercased(),
                            email:email.lowercased(),
                            password:password,
                            passwordConfirm:passwordConfirmation,
                            deviceName:UIDevice.current.name
                        )
                    }
                } label:{
                    HStack {
                        if auth.isLoading { ProgressView().tint(.white) }
                        Text(auth.isLoading ? "" : "Sign Up")
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.black)
                    .clipShape(.capsule)
                    .foregroundStyle(.white)
                    .bold()
                    .padding(.horizontal)
                }
                .disabled(auth.isLoading || email.isEmpty || username.isEmpty || password.isEmpty || password != passwordConfirmation || name.isEmpty || username.isEmpty)
                .frame(height: 45)
                .padding(.top, 8)
                
                if auth.errorMessage != nil {
                    Text(auth.errorMessage!)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            isNameFocused = true
        }
        
    }
}

private extension RegisterView {
    @ViewBuilder
    func iconField<Content: View>(systemImage: String, tint: Color = .secondary, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(width: 20)
            Divider()
                .frame(height: 24)
                .overlay(Color.secondary.opacity(0.3))
            content()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    RegisterView().environmentObject(AuthViewModel())
}
