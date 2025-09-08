import Foundation
import WatchConnectivity

class IPhoneScoreboardSync : NSObject, WCSessionDelegate {
    
    static let shared = IPhoneScoreboardSync()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendScore(_ score: Int) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["score": score], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
}
