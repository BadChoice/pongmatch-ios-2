import HealthKit
import Combine

class TableTennisWorkoutManager: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    
    static let shared = TableTennisWorkoutManager()
        
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    
    func start(){
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tableTennis
        configuration.locationType = .indoor    //TODO: Dynamic
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session?.delegate = self
            session?.startActivity(with: Date())
        } catch {
            print("Failed to start workout: \(error)")
        }
    }
    
    func finish(){
        session?.stopActivity(with: Date())
    }
    
    // MARK: HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }

}
