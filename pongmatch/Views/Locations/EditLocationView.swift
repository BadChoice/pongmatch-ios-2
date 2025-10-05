import SwiftUI
import UIKit

struct EditLocationView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    
    // Form fields
    @State private var name: String
    @State private var isPrivate: Bool
    @State private var isIndoor: Bool
    @State private var numberOfTables: Int
    @State private var descriptionText: String
    @State private var instructions: String
    
    // Image
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    
    // State
    @StateObject private var saving = ApiAction()
    @StateObject private var deleting = ApiAction()
    @State private var showError: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showDeleteConfirm: Bool = false
    
    // Desired landscape aspect ratio for location photos
    private let desiredPhotoAspect: CGFloat = 16.0 / 9.0
    
    init(location: Location) {
        self.location = location
        _name = State(initialValue: location.name)
        _isPrivate = State(initialValue: location.isPrivate ?? false)
        _isIndoor = State(initialValue: location.isIndoor)
        _numberOfTables = State(initialValue: location.number_of_tables ?? 1)
        _descriptionText = State(initialValue: location.description ?? "")
        _instructions = State(initialValue: location.instructions ?? "")
    }
    
    private var fieldsChanged: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines) != location.name ||
        (location.isPrivate ?? false) != isPrivate ||
        location.isIndoor != isIndoor ||
        (location.number_of_tables ?? 1) != numberOfTables ||
        (location.description ?? "") != descriptionText.trimmingCharacters(in: .whitespacesAndNewlines) ||
        (location.instructions ?? "") != instructions.trimmingCharacters(in: .whitespacesAndNewlines) ||
        selectedImage != nil
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        numberOfTables > 0 &&
        !saving.loading &&
        !deleting.loading &&
        fieldsChanged
    }
    
    var body: some View {
        Form {
            Section {
                if let newImage = selectedImage {
                    VStack(alignment: .leading) {
                        Image(uiImage: newImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(8)
                        
                        HStack {
                            Button(role: .destructive) {
                                selectedImage = nil
                            } label: {
                                Label("Remove selected", systemImage: "trash")
                            }
                            Spacer()
                            Button {
                                showImagePicker = true
                            } label: {
                                Label("Change photo", systemImage: "photo.on.rectangle.angled")
                            }
                        }
                        .padding(.top)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        if let urlString = location.photo, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 180)
                                        .clipped()
                                        .cornerRadius(8)
                                case .empty:
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(height: 180)
                                        ProgressView()
                                    }
                                case .failure:
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.15))
                                        .overlay {
                                            Label("No photo", systemImage: "photo")
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(height: 180)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                                .overlay {
                                    Label("No photo", systemImage: "photo")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(height: 120)
                        }
                        
                        Button {
                            showImagePicker = true
                        } label: {
                            Label("Change photo", systemImage: "photo")
                        }
                    }
                }
            }
            
            Section("Basic info") {
                TextField("Name", text: $name)
                    .textContentType(.name)
                
                Toggle("Private", isOn: $isPrivate)
                Toggle("Indoor", isOn: $isIndoor)
                
                Stepper(value: $numberOfTables, in: 1...50) {
                    HStack {
                        Text("Number of tables")
                        Spacer()
                        Text("\(numberOfTables)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Location") {
                if let address = location.address, !address.isEmpty {
                    Label(address, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Latitude: \(location.coordinates.latitude)", systemImage: "mappin")
                        Label("Longitude: \(location.coordinates.longitude)", systemImage: "mappin")
                    }
                    .foregroundStyle(.secondary)
                }
                Text("Address and coordinates cannot be changed here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Section("Details") {
                TextField("Description", text: $descriptionText, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Instructions (how to get in, etc.)", text: $instructions, axis: .vertical)
                    .lineLimit(1...3)
            }
            
            if saving.loading || deleting.loading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView(saving.loading ? "Saving…" : "Deleting…")
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete Location", systemImage: "trash")
                }
                .disabled(saving.loading || deleting.loading)
            }
        }
        .navigationTitle("Edit Location")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .disabled(!canSave)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            // Use same approach as CreateLocationView: disable system crop; crop to 16:9 ourselves.
            ImagePicker(image: $selectedImage, allowsCropping: false)
        }
        .onChange(of: selectedImage) { _, newValue in
            guard let img = newValue else { return }
            let currentAspect = img.size.width / max(img.size.height, 1)
            if abs(currentAspect - desiredPhotoAspect) > 0.02 {
                selectedImage = img.croppedToAspect(desiredPhotoAspect)
            }
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error")
        })
        .confirmationDialog(
            "Are you sure you want to delete this location?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Location", role: .destructive) {
                Task { await deleteLocation() }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Actions
    
    @MainActor
    private func save() async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInstructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let _ = await saving.run {
            do {
                let updated = try await auth.api!.update(
                    location: location,
                    name: trimmedName,
                    isPrivate: isPrivate,
                    isIndoor: isIndoor,
                    numberOfTables: numberOfTables,
                    description: trimmedDescription,
                    instructions: trimmedInstructions
                )
                
                if let image = selectedImage {
                    let _ = try await auth.api!.uploadLocationAvatar(updated, image: image)
                }
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "\(error)"
                    showError = true
                }
            }
        }
    }
    
    @MainActor
    private func deleteLocation() async {
        let _ = await deleting.run {
            do {
                try await auth.api!.delete(location: location)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "\(error)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - UIImage helpers (same as in CreateLocationView)
private extension UIImage {
    // aspectRatio = width / height (e.g., 16/9)
    func croppedToAspect(_ aspectRatio: CGFloat) -> UIImage {
        guard let cg = self.cgImage else { return self }
        
        let widthPx  = CGFloat(cg.width)
        let heightPx = CGFloat(cg.height)
        let currentAspect = widthPx / max(heightPx, 1)
        
        var cropWidth  = widthPx
        var cropHeight = heightPx
        
        if currentAspect > aspectRatio {
            cropWidth = heightPx * aspectRatio
        } else {
            cropHeight = widthPx / aspectRatio
        }
        
        let x = (widthPx  - cropWidth)  / 2.0
        let y = (heightPx - cropHeight) / 2.0
        let cropRect = CGRect(x: x.rounded(.down), y: y.rounded(.down),
                              width: cropWidth.rounded(.down), height: cropHeight.rounded(.down))
        
        guard let croppedCG = cg.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: croppedCG, scale: self.scale, orientation: self.imageOrientation)
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        EditLocationView(location: Location.fake())
    }.environmentObject(auth)
}
