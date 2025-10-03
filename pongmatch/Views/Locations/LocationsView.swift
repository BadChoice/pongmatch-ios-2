import SwiftUI
import MapKit
import CoreLocation
import Combine
internal import RevoFoundation

struct LocationInMap : Identifiable {
    var id:Int {
        location.id
    }
    
    let location: Location
    
    var coordinate:CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: location.coordinates.latitude, //Laravel POINT has them swapped
            longitude: location.coordinates.longitude
        )
    }
}

struct LocationsView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var locationManager = LocationManager.shared
    
    @StateObject var searchingLocations = ApiAction()
    
    @State var locations:[Location] = []
    
    @State private var cameraPosition:MapCameraPosition = .userLocation(fallback: .automatic)
        
    @State private var selectedLocation:LocationInMap? = nil
    @State private var selectedLocationId:Int? = nil
    
    // Track last center we fetched for, to avoid spamming the API
    @State private var lastRequestedCenter: CLLocationCoordinate2D? = nil
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedLocationId) {
            UserAnnotation()
            ForEach(locations, id: \.id) { location in
                Marker(coordinate: LocationInMap(location: location).coordinate) {
                    Label(location.name, systemImage: "figure.table.tennis.circle.fill")
                }
                .tint(location.isIndoor ? .blue : .red)
                .tag(location.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            let center = context.region.center
            Task { await fetchLocations(around: center) }
        }
        .overlay(alignment: .bottom) {
            if !locationManager.isAuhtorized {
                VStack {
                    Label("Location access is denied. Please enable it in Settings.", systemImage: "location.slash")
                        .padding(.top, 12)
                    Button {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    } label: {
                        Text("Open Settings")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                            .bold()
                    }
                }
                .padding()
                .glassEffect()
                .padding(.bottom)
                    
            }
        }
        //.navigationTitle("Locations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CreateLocationView()
                } label: {
                    Image(systemName: "plus")
                }
            }
                
        }
        .onChange(of: selectedLocationId) { _, newValue in
            guard let id = newValue else {
                selectedLocation = nil
                return
            }
            selectedLocation = LocationInMap(location: locations.first(where: { $0.id == id })!)
        }
        .sheet(item: $selectedLocation) { location in
            LocationInfo(location: location.location)
                .presentationDetents([.fraction(0.40), .medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Fetching
    
    private func shouldFetch(for center: CLLocationCoordinate2D) -> Bool {
        guard let last = lastRequestedCenter else { return true }
        let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
        let newLoc  = CLLocation(latitude: center.latitude, longitude: center.longitude)
        // Only fetch if moved more than 100 meters
        return lastLoc.distance(from: newLoc) > 100
    }
    
    @MainActor
    private func fetchLocations(around center: CLLocationCoordinate2D) async {
        guard shouldFetch(for: center) else { return }
        let _ = await searchingLocations.run {
            let foundLocations = try await auth.api!.locations(latitude: center.latitude, longitude: center.longitude)
            locations.append(contentsOf: foundLocations)
            locations = locations.unique(\.id)
            lastRequestedCenter = center
        }
    }
}
    
private struct LocationInfo: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State var location: Location
    @StateObject var fetchingLocation = ApiAction()
    
    var body: some View {
        VStack(alignment: .leading) {
            if fetchingLocation.loading {
                Spacer().frame(height: 150)
                Text(location.name)
                    .font(.title)
                    .foregroundStyle(.primary)
                HStack {
                    ProgressView()
                    EmptyView()
                    ProgressView()
                }
            } else {
                AsyncImage(url: Images.location(location.photo)) { image in
                    image.image?.resizable()
                        .frame(height: 150)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(location.name)
                        .font(.title)
                        .foregroundStyle(.primary)
                    
                    HStack {
                        Tag("\(location.number_of_tables ?? 0)", icon: "table")
                        
                        if location.isPrivate ?? false {
                            Tag("Private", icon: "lock.fill")
                        }else{
                            Tag("Public", icon: "lock.open.fill")
                        }
                        
                        if location.isIndoor {
                            Tag("Indoor", icon: "house.fill", color: .blue)
                        } else {
                            Tag("Outdoor", icon: "sun.max.fill", color: .red)
                        }
                        Spacer()
                    }
                                                                                             
                    if let address = location.address {
                        Label(address, systemImage: "mappin.and.ellipse")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    
                    if let instructions = location.instructions {
                        Label(instructions, systemImage: "info.circle")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    Text(location.description ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .task {
            let _ = await fetchingLocation.run {
                location = try await auth.api!.location(id: location.id)
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
                LocationsView()
            }
        }
    }.environmentObject(auth)
}
