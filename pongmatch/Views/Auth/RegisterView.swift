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
        VStack {            

            TextField("Name", text: $name)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
                .focused($isNameFocused)

            if !isNameValid && !name.isEmpty {
                Text("Name must be at least 3 characters.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            TextField("Username", text: $username)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)

            if !isUsernameValid && !username.isEmpty {
                Text("Username must be >3 characters and have no spaces.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            
            if !isEmailValid && !email.isEmpty {
                Text("Enter a valid email address.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Divider().padding(.vertical)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            
            SecureField("Password Confirmation", text: $passwordConfirmation)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
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
                    if auth.isLoading { ProgressView() }
                    Text(auth.isLoading ? "" : "Sign Up")
                }
            }
            .disabled(auth.isLoading || email.isEmpty || username.isEmpty || password.isEmpty || password != passwordConfirmation || name.isEmpty || username.isEmpty)
            .frame(height: 45)
            .padding(.horizontal)
            
            if auth.errorMessage != nil {
                Text(auth.errorMessage!)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            isNameFocused = true
        }
        
    }
}

#Preview {
    RegisterView().environmentObject(AuthViewModel())
}
