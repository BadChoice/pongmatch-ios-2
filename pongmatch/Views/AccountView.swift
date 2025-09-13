import SwiftUI

struct AccountView : View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var name: String = ""
    @State private var language: String = "English"
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var acceptChallengesFrom: AcceptChallengeRequestFrom = .following
    @State private var avatarImage: Image? = nil
    @State private var showImagePicker = false
    @State private var inputImage: UIImage? = nil
    
    let languages = ["English", "Spanish", "Catalan", "French", "German", "Chinese"]
    
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
                    ForEach(languages, id: \ .self) { lang in
                        Text(lang)
                    }
                }
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
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
                Button("Save") {
                    // Save logic: update user profile via auth/api
                }
            }
        }
        .onAppear {
            let user = auth.user
            name = user?.name ?? ""
            language = user?.language ?? "English"
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

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return AccountView().environmentObject(auth)
}
