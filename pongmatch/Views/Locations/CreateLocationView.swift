import SwiftUI
import UIKit
import CoreLocation
import MapKit
import Contacts
import Combine

private final class AddressSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    let completer: MKLocalSearchCompleter
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func update(query: String) {
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }
}

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
    
    // Address autocomplete
    @StateObject private var addressSearch = AddressSearchCompleter()
    
    // Map (iOS 17+ modern Map API)
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Desired landscape aspect ratio for location photos
    private let desiredPhotoAspect: CGFloat = 16.0 / 9.0
    
    private var latitude: Double? {
        Double(latitudeText.replacingOccurrences(of: ",", with: "."))
    }
    private var longitude: Double? {
        Double(longitudeText.replacingOccurrences(of: ",", with: "."))
    }
    private var selectedCoordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        latitude != nil &&
        longitude != nil &&
        numberOfTables > 0
    }
    
    var body: some View {
        Form {
            Section("Photo") {
                if let image = selectedImage {
                    VStack(alignment: .leading) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180) // landscape preview
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
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        TextField("Address", text: $address, axis: .vertical)
                            .lineLimit(1...3)
                            .onChange(of: address) { _, newValue in
                                addressSearch.update(query: newValue)
                            }
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                        
                        if geocoding {
                            ProgressView().controlSize(.small)
                        }
                        
                        Button {
                            useCurrentLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .imageScale(.medium)
                                .padding(6)
                        }
                        .buttonStyle(.borderless)
                        .disabled(!locationManager.isAuhtorized && locationManager.userLocation == nil)
                        .help("Use Current Location")
                    }
                    
                    if !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !addressSearch.results.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(addressSearch.results.enumerated()), id: \.offset) { index, completion in
                                Button {
                                    Task { await selectAddressCompletion(completion) }
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(completion.title)
                                            .foregroundStyle(.primary)
                                        if !completion.subtitle.isEmpty {
                                            Text(completion.subtitle)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .padding(.vertical, 6)
                                
                                if index < addressSearch.results.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Always show the map; add a pin when coordinates are selected
                    Map(position: $mapPosition) {
                        if let coord = selectedCoordinate {
                            Marker(coordinate: coord) {
                                Label("Selected location", systemImage: "mappin.circle.fill")
                            }
                            .tint(.red)
                        }
                        UserAnnotation()
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Section("Details") {
                TextField("Description", text: $descriptionText, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Instructions (how to get in, etc.)", text: $instructions, axis: .vertical)
                    .lineLimit(1...3)
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
            // Disable the system’s square crop UI; we’ll crop to landscape ourselves.
            ImagePicker(image: $selectedImage, allowsCropping: false)
        }
        .onChange(of: selectedImage) { _, newValue in
            guard let img = newValue else { return }
            let currentAspect = img.size.width / max(img.size.height, 1)
            // Only crop if not already ~16:9
            if abs(currentAspect - desiredPhotoAspect) > 0.02 {
                selectedImage = img.croppedToAspect(desiredPhotoAspect)
            }
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error")
        })
        .task {
            // Prefill from current location and bias autocomplete
            if let loc = locationManager.userLocation {
                setCoordinates(from: loc.coordinate)
                await reverseGeocodeIfNeeded(for: loc)
                
                addressSearch.completer.region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                )
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
                let created = try await auth.api!.locations.create(
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
                
                if let image = selectedImage {
                    _ = try await auth.api!.locations.uploadAvatar(created, image: image)
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
    
    private func setCoordinates(from coord: CLLocationCoordinate2D) {
        latitudeText = String(coord.latitude)
        longitudeText = String(coord.longitude)
        // Center the map on the selected coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        mapPosition = .region(MKCoordinateRegion(center: coord, span: span))
    }
    
    // Resolve a selected suggestion to coordinates and a formatted address
    private func selectAddressCompletion(_ completion: MKLocalSearchCompletion) async {
        geocoding = true
        defer { geocoding = false }
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            search.start { response, error in
                if let item = response?.mapItems.first {
                    let coord = item.placemark.coordinate
                    setCoordinates(from: coord)
                    
                    if let postal = item.placemark.postalAddress {
                        let formatted = CNPostalAddressFormatter.string(from: postal, style: .mailingAddress)
                            .replacingOccurrences(of: "\n", with: ", ")
                        self.address = formatted
                    } else {
                        let composed = [completion.title, completion.subtitle]
                            .filter { !$0.isEmpty }
                            .joined(separator: ", ")
                        if !composed.isEmpty {
                            self.address = composed
                        }
                    }
                } else if let error {
                    self.errorMessage = "Could not resolve address: \(error.localizedDescription)"
                    self.showError = true
                } else {
                    self.errorMessage = "Could not resolve the selected address."
                    self.showError = true
                }
                continuation.resume()
            }
        }
    }
    
    // Optional fallback: geocode freeform address if you want to support "enter then press return"
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

// MARK: - UIImage helpers

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
            // Too wide — limit width
            cropWidth = heightPx * aspectRatio
        } else {
            // Too tall — limit height
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
    
    return TabView {
        Tab {
            NavigationStack {
                CreateLocationView()
            }
        }
    }.environmentObject(auth)
}
