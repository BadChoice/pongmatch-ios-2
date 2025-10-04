import SwiftUI
import UIKit
import CoreLocation
import MapKit
import Contacts
import Combine

private enum LocationInputMode: String, CaseIterable, Identifiable {
    case current = "Current Location"
    case address = "Address"
    var id: Self { self }
}

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
    
    // Location input mode + address autocomplete
    @State private var locationInputMode: LocationInputMode = .current
    @StateObject private var addressSearch = AddressSearchCompleter()
    
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
                Picker("Location Input", selection: $locationInputMode) {
                    ForEach(LocationInputMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                switch locationInputMode {
                case .current:
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
                    
                    if let lat = latitude, let lon = longitude {
                        HStack {
                            Text("Selected coordinates")
                            Spacer()
                            Text(String(format: "%.6f, %.6f", lat, lon))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                case .address:
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Search for an address", text: $address, axis: .vertical)
                                .lineLimit(1...3)
                                .onChange(of: address) { _, newValue in
                                    addressSearch.update(query: newValue)
                                }
                            
                            if geocoding {
                                ProgressView().controlSize(.small)
                            }
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
                        
                        if let lat = latitude, let lon = longitude {
                            HStack {
                                Text("Selected coordinates")
                                Spacer()
                                Text(String(format: "%.6f, %.6f", lat, lon))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
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
            ImagePicker(image: $selectedImage, allowsCropping: true)
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error")
        })
        .task {
            // Prefill and default mode
            if let loc = locationManager.userLocation {
                locationInputMode = .current
                setCoordinates(from: loc.coordinate)
                await reverseGeocodeIfNeeded(for: loc)
                
                // Optional: bias autocomplete around user location
                addressSearch.completer.region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
            } else {
                locationInputMode = .address
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
    
    // Fallback geocoder (not used by UI now, but kept in case you want to trigger it elsewhere)
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
