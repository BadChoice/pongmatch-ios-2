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
    
    func fetchSyncedScore() -> Score? {
        scoreFromContext(WCSession.default.receivedApplicationContext)
    }

    // Send to iphone
    func onScoreUpdated() {
        guard let data = try? JSONEncoder().encode(score) else {
            return
        }

        try? WCSession.default.updateApplicationContext(["score" : data])
    }
    
    func clearScore(){
        var context = WCSession.default.receivedApplicationContext
        context.removeValue(forKey: "score") // remove the key
        try? WCSession.default.updateApplicationContext(context)
    }
        
    // Receive from iPhone
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        guard let score = scoreFromContext(applicationContext) else { return }
        
        DispatchQueue.main.async {
            self.score = score
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    private func scoreFromContext(_ context: [String: Any]) -> Score? {
        guard let data = context["score"] as? Data else {
            return nil
        }
        guard let score = try? JSONDecoder().decode(Score.self, from: data) else {
            return nil
        }
        
        return score
    }
}
