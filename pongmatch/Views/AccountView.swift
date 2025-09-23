import SwiftUI

struct AccountView : View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var language: Language = .english
    @State private var phonePrefix: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var acceptChallengesFrom: AcceptChallengeRequestFrom = .following
    @State private var avatarImage: Image? = nil
    @State private var showImagePicker = false
    @State private var inputImage: UIImage? = nil
    
    @State private var saving = false
    @State private var savingAvatar = false
    
    @State private var errorMessage: String? = nil
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        if let avatarImage = avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let url = Images.avatar(auth.user?.avatar ?? "") {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        if savingAvatar {
                            ProgressView()
                        }
                        
                        Button("Change Avatar") {
                            showImagePicker = true
                        }
                    }
                    Spacer()
                }
            }
            Section(header: Text("Account Info")) {
                HStack {
                    Text("Username")
                    Spacer()
                    Text(auth.user?.username ?? "-")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text(auth.user?.email ?? "-")
                        .foregroundColor(.secondary)
                }
            }
            Section(header: Text("Personal Info")) {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                        .textContentType(.name)
                        .autocorrectionDisabled(false)
                }
                LabeledContent("Language") {
                    Picker("", selection: $language) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.description).tag(lang)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                LabeledContent("Phone") {
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Address") {
                    TextField("Address", text: $address)
                        .textContentType(.fullStreetAddress)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section(header: Text("Challenge Acceptance")) {
                VStack {
                    Picker("Accept Challenges From", selection: $acceptChallengesFrom) {
                        ForEach(AcceptChallengeRequestFrom.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("Select who can challenge you to a match. You will still have the option to accept or decline it.")
                        .padding(.vertical, 4)
                        .font(Font.caption)
                        .foregroundStyle(.secondary)
                }
                
            }
            Section {
                if saving {
                    ProgressView()
                } else {
                    HStack {
                        Spacer()
                        Button {
                            Task { await saveProfile() }
                        } label: {
                            HStack{
                                if saving { ProgressView() }
                                Text("Save")
                            }
                        }
                        Spacer()
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }.onAppear {
            let user = auth.user
            name = user?.name ?? ""
            language = user?.language ?? .english
            phonePrefix = user?.phone_prefix ?? ""
            phone = user?.phone ?? ""
            address = user?.address ?? ""
            acceptChallengesFrom = user?.accept_challenge_requests_from ?? .followers
        }
        .onChange(of: inputImage) { _, newImage in
            if let newImage = newImage {
                avatarImage = Image(uiImage: newImage)
                Task {
                    savingAvatar = true
                    defer { savingAvatar = false }
                    do{
                        let newUser = try await auth.api.uploadAvatar(newImage)
                        auth.user = newUser
                    } catch {
                        
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage, allowsCropping: true)
        }
    }
    
    private func saveProfile() async{
        saving = true
        defer { saving = false  }
        do {
            let updatedUser = try await auth.api.updateProfile(
                name: name,
                language: language,
                timeZone: TimeZone.current.identifier,
                phonePrefix: phonePrefix,
                phone: phone,
                address: address,
                acceptChallengesFrom: acceptChallengesFrom
            )
            auth.user = updatedUser
            dismiss()
        } catch {
            errorMessage = "Failed to save profile: \(error)"
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return AccountView().environmentObject(auth)
}
