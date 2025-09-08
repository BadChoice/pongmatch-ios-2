import Foundation
import Combine
import WatchConnectivity

class IPhoneScoreboardSync : NSObject, ObservableObject, WCSessionDelegate {
    
    static let shared = IPhoneScoreboardSync()

    @Published var score:Score!
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Send to iphone
    func onScoreUpdated() {
        guard let data = try? JSONEncoder().encode(score) else {
            return
        }

        try? WCSession.default.updateApplicationContext(["score" : data])
    }
        
    // Receive from iPhone
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        guard let data = applicationContext["score"] as? Data else { return }
        guard let score = try? JSONDecoder().decode(Score.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.score = score
            print("Got score")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
}
