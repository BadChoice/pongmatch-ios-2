import Foundation
import Combine
import WatchConnectivity

class AppleWatchScoreboardSync: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = AppleWatchScoreboardSync()
    
    @Published var score:Score!
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // Send to watch
    func onScoreUpdated() {
        guard let data = try? JSONEncoder().encode(score) else {
            return
        }

        try? WCSession.default.updateApplicationContext(["score" : data])
    }
    
    // Receive from watch
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any]) {

        guard let data = applicationContext["score"] as? Data else { return }
        guard let score = try? JSONDecoder().decode(Score.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.score = score
            print("Got score")
        }
    }
    
    // MARK: - Session delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
