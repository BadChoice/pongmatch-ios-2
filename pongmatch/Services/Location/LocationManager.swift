import SwiftUI
import CoreLocation

@Observable
class LocationManager : NSObject, CLLocationManagerDelegate {
    @ObservationIgnored let manager = CLLocationManager()
    
    static var shared = LocationManager()
    
    var userLocation:CLLocation?
    var isAuhtorized = false
    
    override init() {
        super.init()
        manager.delegate = self
        startLocationServices()
    }
    
    func startLocationServices(){
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isAuhtorized = true
            return
        }
        isAuhtorized = false
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuhtorized = true
            manager.requestLocation()
            
        case .notDetermined:
            isAuhtorized = false
            manager.requestWhenInUseAuthorization()
            
        case .denied:
            isAuhtorized = false
            print("Acces denied")
        
        default:
            isAuhtorized = true
            startLocationServices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}
