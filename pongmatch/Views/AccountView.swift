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
    
    @StateObject private var savingAvatar = ApiAction()
    @StateObject private var savingProfile = ApiAction()
    @StateObject private var deletingAccount = ApiAction()
    
    @State private var showDeleteSheet = false
    @State private var deleteConfirmationText = ""
    
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
                        if savingAvatar.loading {
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
                HStack {
                    Spacer()
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        HStack {
                            if savingProfile.loading { ProgressView() }
                            Text("Save")
                        }
                    }
                    .disabled(savingProfile.loading)
                    Spacer()
                }
                
                if let errorMessage = savingProfile.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section(header: Text("Danger Zone")) {
                VStack(spacing: 12) {
                    Button(role: .destructive) {
                        showDeleteSheet = true
                    } label: {
                        Text("Delete Account")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(deletingAccount.loading)
                    
                    Text("This will permanently delete your account and all associated data. This action cannot be undone.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
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
                    await savingAvatar.run {
                        auth.user = try await auth.api.uploadAvatar(newImage)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage, allowsCropping: true)
        }
        .sheet(isPresented: $showDeleteSheet) {
            deleteAccountSheet
        }
    }
    
    private func saveProfile() async{
        let saved = await savingProfile.run {
            auth.user = try await auth.api.updateProfile(
                name: name,
                language: language,
                timeZone: TimeZone.current.identifier,
                phonePrefix: phonePrefix,
                phone: phone,
                address: address,
                acceptChallengesFrom: acceptChallengesFrom
            )
        }
        
        if saved {
            dismiss()
        }
    }
    
    private var deleteAccountSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("Delete Account")
                        .font(.title2.bold())
                }
                
                Text("This will permanently delete your account and all associated data. This action cannot be undone.")
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type “delete” to confirm:")
                        .font(.subheadline)
                    TextField("delete", text: $deleteConfirmationText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .textFieldStyle(.roundedBorder)
                }
                
                if let error = deletingAccount.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
                
                Button(role: .destructive) {
                    Task { await performDeleteAccount() }
                } label: {
                    HStack {
                        if deletingAccount.loading { ProgressView() }
                        Text("Permanently Delete Account")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!canConfirmDelete || deletingAccount.loading)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDeleteSheet = false
                        deleteConfirmationText = ""
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var canConfirmDelete: Bool {
        deleteConfirmationText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "delete"
    }
    
    private func performDeleteAccount() async {
        let deleted = await deletingAccount.run {
            try await auth.api.deleteAccount()
        }
        if deleted {
            showDeleteSheet = false
            deleteConfirmationText = ""
            auth.logout()
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return AccountView().environmentObject(auth)
}

