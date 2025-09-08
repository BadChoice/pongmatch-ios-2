import Foundation
import Combine
import WatchConnectivity

class PhoneConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneConnectivity()
    
    @Published var score: (Int, Int) = (0, 0)
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func updateScore(_ newScore: (Int, Int)) {
        score = newScore
        
        // Send to watch
        let data: [String: Any] = [
            "player1": newScore.0,
            "player2": newScore.1
        ]
        try? WCSession.default.updateApplicationContext(data)
    }
    
    // Receive from watch
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            let p1 = applicationContext["player1"] as? Int ?? 0
            let p2 = applicationContext["player2"] as? Int ?? 0
            self.score = (p1, p2)
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
