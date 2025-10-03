import SwiftUI
import UIKit
import CoreLocation

struct CreateLocationView : View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var locationManager = LocationManager.shared
    
    // Form fields
    @State private var name: String = ""
    @State private var isPrivate: Bool = false
    @State private var isIndoor: Bool = true
    @State private var numberOfTables: Int = 1
    @State private var descriptionText: String = ""
    @State private var instructions: String = ""
    @State private var address: String = ""
    
    // Coordinates
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    
    // Image
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    
    // State
    @StateObject private var creating = ApiAction()
    @State private var geocoding: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    private var latitude: Double? {
        Double(latitudeText.replacingOccurrences(of: ",", with: "."))
    }
    private var longitude: Double? {
        Double(longitudeText.replacingOccurrences(of: ",", with: "."))
    }
    
    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        latitude != nil &&
        longitude != nil &&
        numberOfTables > 0
    }
    
    var body: some View {
        Form {
            Section("Basic info") {
                TextField("Name", text: $name)
                    .textContentType(.name)
                
                Toggle("Private", isOn: $isPrivate)
                Toggle("Indoor", isOn: $isIndoor)
                
                Stepper(value: $numberOfTables, in: 1...20) {
                    HStack {
                        Text("Number of tables")
                        Spacer()
                        Text("\(numberOfTables)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Location") {
                HStack {
                    Button {
                        useCurrentLocation()
                    } label: {
                        Label("Use Current Location", systemImage: "location.fill")
                    }
                    .disabled(!locationManager.isAuhtorized && locationManager.userLocation == nil)
                    
                    Spacer()
                    
                    if geocoding {
                        ProgressView().controlSize(.small)
                    }
                }
                
                TextField("Address (optional, we can geocode it)", text: $address, axis: .vertical)
                    .lineLimit(1...3)
                
                Button {
                    Task { await geocodeAddress() }
                } label: {
                    Label("Geocode address", systemImage: "mappin.and.ellipse")
                }
                .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || geocoding)
                
                /*
                HStack {
                    Text("Latitude")
                    TextField("lat", text: $latitudeText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(latitude == nil ? .red : .primary)
                }
                HStack {
                    Text("Longitude")
                    TextField("lon", text: $longitudeText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(longitude == nil ? .red : .primary)
                }
                 */
            }
            
            Section("Details") {
                TextField("Description", text: $descriptionText, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Instructions (how to get in, etc.)", text: $instructions, axis: .vertical)
                    .lineLimit(1...3)
            }
            
            Section("Photo") {
                if let image = selectedImage {
                    VStack(alignment: .leading) {
                        Image(uiImage: image)
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
                                Label("Remove photo", systemImage: "trash")
                            }
                            Spacer()
                            Button {
                                showImagePicker = true
                            } label: {
                                Label("Change photo", systemImage: "photo.on.rectangle.angled")
                            }
                        }.padding(.top)
                    }
                } else {
                    Button {
                        showImagePicker = true
                    } label: {
                        Label("Pick a photo", systemImage: "photo")
                    }
                }
                
                // NOTE: When you add the API for uploading a location photo, call it right after creation:
                // try await auth.api.uploadLocationPhoto(createdLocation, image: selectedImage)
            }
            
            if creating.loading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Creating location…")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("New Location")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await createLocation() }
                } label: {
                    Text("Create").bold()
                }
                .disabled(!canCreate || creating.loading)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, allowsCropping: true)
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error")
        })
        .task {
            // Prefill with current location if available
            if let loc = locationManager.userLocation {
                setCoordinates(from: loc.coordinate)
                await reverseGeocodeIfNeeded(for: loc)
            }
        }
    }
    
    // MARK: - Actions
    
    private func useCurrentLocation() {
        if let loc = locationManager.userLocation {
            setCoordinates(from: loc.coordinate)
            Task { await reverseGeocodeIfNeeded(for: loc) }
        } else {
            errorMessage = "Current location is not available. Please check location permissions."
            showError = true
        }
    }
    
    @MainActor
    private func createLocation() async {
        guard let lat = latitude, let lon = longitude else {
            errorMessage = "Please provide valid coordinates."
            showError = true
            return
        }
        
        let _ = await creating.run {
            do {
                let created = try await auth.api!.createLocation(
                    name: name,
                    isPrivate: isPrivate,
                    isIndoor: isIndoor,
                    numberOfTables: numberOfTables,
                    description: descriptionText,
                    instructions: instructions,
                    address: address,
                    longitude: lon,
                    latitude: lat
                )
                
                // TODO: When the API is available, upload the photo here.
                // if let image = selectedImage {
                //     _ = try await auth.api!.uploadLocationPhoto(created, image: image)
                // }
                
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
    
    private func setCoordinates(from coord: CLLocationCoordinate2D) {
        latitudeText = String(coord.latitude)
        longitudeText = String(coord.longitude)
    }
    
    private func geocodeAddress() async {
        guard !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        geocoding = true
        defer { geocoding = false }
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                if let loc = placemarks?.first?.location {
                    setCoordinates(from: loc.coordinate)
                } else if let error {
                    self.errorMessage = "Could not geocode address: \(error.localizedDescription)"
                    self.showError = true
                } else {
                    self.errorMessage = "Could not find coordinates for the given address."
                    self.showError = true
                }
                continuation.resume()
            }
        }
    }
    
    private func reverseGeocodeIfNeeded(for location: CLLocation) async {
        guard address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    var parts: [String] = []
                    if let name = placemark.name { parts.append(name) }
                    if let locality = placemark.locality { parts.append(locality) }
                    if let administrativeArea = placemark.administrativeArea { parts.append(administrativeArea) }
                    if let postalCode = placemark.postalCode { parts.append(postalCode) }
                    if let country = placemark.country { parts.append(country) }
                    let composed = parts.joined(separator: ", ")
                    if !composed.isEmpty {
                        self.address = composed
                    }
                }
                continuation.resume()
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return TabView {
        Tab {
            NavigationStack {
                CreateLocationView()
            }
        }
    }.environmentObject(auth)
}
