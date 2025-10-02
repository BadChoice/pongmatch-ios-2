import SwiftUI

struct EditGroupView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var group: PMGroup

    @State private var name: String
    @State private var description: String
    @State private var isPrivate: Bool
    @State private var inputImage: UIImage? = nil
    @State private var newImagePreview: Image?
    @State private var showImagePicker = false
    
    @StateObject private var updatingGroup = ApiAction()
    
    init(group: Binding<PMGroup>) {
        self._group = group
        // Initialize edit fields from the binding
        _name = State(initialValue: group.wrappedValue.name)
        _description = State(initialValue: group.wrappedValue.description ?? "")
        _isPrivate = State(initialValue: group.wrappedValue.isPrivate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let newImagePreview = newImagePreview {
                                newImagePreview
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                GroupImage(group: group, size: 100)
                            }
                            Button("Change Group Image") {
                                showImagePicker = true
                            }
                        }
                        Spacer()
                    }
                }
                Section(header: Text("Group Info")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                Section {
                    Toggle("Private group", isOn: $isPrivate)
                }
                if let errorMessage = updatingGroup.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .disabled(updatingGroup.loading)
            .navigationTitle("Edit Group")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!fieldsChanged || name.trimmingCharacters(in: .whitespaces).isEmpty || updatingGroup.loading)
                }
            }
            .overlay {
                if updatingGroup.loading {
                    ZStack {
                        Color.black.opacity(0.1).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $inputImage, allowsCropping: true)
            }
            .onChange(of: inputImage) { _, newImage in
                uploadAvatar()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // Detect if user changed any field/image
    private var fieldsChanged: Bool {
        name.trimmingCharacters(in: .whitespaces) != group.name ||
        (description.trimmingCharacters(in: .whitespaces) != (group.description ?? "")) ||
        isPrivate != group.isPrivate ||
        inputImage != nil
    }
    
    private func save() {
        Task {
            let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
            
            // Simulate updating group locally
            group = PMGroup(
                id: group.id,
                name: name.trimmingCharacters(in: .whitespaces),
                description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                token: group.token,
                photo: group.photo, // will update if upload image
                isPrivate: isPrivate,
                usersCount: group.usersCount,
                created_at: group.created_at,
                user: group.user
            )
            
            
            let _ = await updatingGroup.run {
                group = try await auth.api.update(group: group)
            }
            
            dismiss()
        }
    }
    
    private func uploadAvatar(){
        Task {
            if let inputImage {
                let _ = await updatingGroup.run {
                    group = try await auth.api.uploadGroupAvatar(group, image:inputImage)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var group = PMGroup.fake()
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return EditGroupView(group: $group)
        .environmentObject(auth)
}
