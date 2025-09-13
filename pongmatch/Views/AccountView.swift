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
                        } else if let url = URL(string: auth.user?.avatar ?? "") {
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
                TextField("Name", text: $name)
                Picker("Language", selection: $language) {
                    ForEach(Language.allCases, id: \ .self) { lang in
                        Text(lang.description)
                    }
                }
                HStack {
                    TextField("Prefix", text: $phonePrefix)
                        .frame(width: 60)
                        .keyboardType(.numberPad)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                TextField("Address", text: $address)
            }
            Section(header: Text("Challenge Acceptance")) {
                Picker("Accept Challenges From", selection: $acceptChallengesFrom) {
                    ForEach(AcceptChallengeRequestFrom.allCases, id: \ .self) { option in
                        Text(option.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section {
                if saving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task { await saveProfile() }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                    
                }
            }
            .onAppear {
                let user = auth.user
                name = user?.name ?? ""
                language = user?.language ?? .english
                phonePrefix = user?.phone_prefix ?? ""
                phone = user?.phone ?? ""
                address = user?.address ?? ""
                acceptChallengesFrom = user?.accept_challenge_requests_from ?? .followers
            }
            .sheet(isPresented: $showImagePicker) {
                //ImagePicker(image: $inputImage)
            }
            .onChange(of: inputImage) { _, newImage in
                if let newImage = newImage {
                    avatarImage = Image(uiImage: newImage)
                    // Optionally upload avatar to backend here
                }
            }
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
