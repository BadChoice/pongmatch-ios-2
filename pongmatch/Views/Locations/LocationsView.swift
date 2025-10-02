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
    
    @StateObject var searchingLocations = ApiAction()

    @State var locations:[Location] = []
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.7226538, longitude: 1.8178933),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedLocation:LocationInMap? = nil
    @State private var selectedLocationId:Int? = nil
    
    var body: some View {
        Map(initialPosition: .region(region), selection: $selectedLocationId) {
            ForEach(locations, id: \.id) { location in
                Marker(location.name, coordinate: LocationInMap(location: location).coordinate)
                    .tag(location.id)
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Locations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Add location
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
        .task {
            let _ = await searchingLocations.run {
                let foundLocations = try await auth.api!.locations(latitude: 41.7226538, longitude: 1.8178933)
                locations.append(contentsOf: foundLocations)
                locations = locations.unique(\.id)
            }
        }
        .sheet(item: $selectedLocation) { location in
            LocationInfo(location: location.location)
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}
    
private struct LocationInfo: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State var location: Location
    @StateObject var fetchingLocation = ApiAction()
    
    var body: some View {
        VStack {
            Text(location.name)
            if fetchingLocation.loading {
                ProgressView()
            } else{
                Text(location.description ?? "")
            }
        }
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
    
    return NavigationStack {
        LocationsView()
    }.environmentObject(auth)
}
