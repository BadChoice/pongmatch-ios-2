import Foundation
import WatchConnectivity

protocol WatchContextDelegate {
    func onContextReceived(applicationContext: [String : Any])
}

protocol WatchUserInfoDelegate {
    func onUserInfoReceived(userInfo: [String : Any])
}

class WatchManager : NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    
    var contextDelegate:WatchContextDelegate?
    var userInfoDelegate:WatchUserInfoDelegate?
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // ============================================================
    // MARK: Context - Live sync when updated - just one state
    // ============================================================
    func removeFromContext(_ key:String){
        guard WCSession.isSupported() else { return }
        var context = WCSession.default.receivedApplicationContext
        context.removeValue(forKey: key) // remove the key
        try? WCSession.default.updateApplicationContext(context)
    }
        
    func updateContext(_ context:[String:Any]){
        guard WCSession.isSupported() else { return }
        try? WCSession.default.updateApplicationContext(context)
    }
    
    func getContext() -> [String:Any] {
        WCSession.default.receivedApplicationContext
    }
    
    // Receive data from context
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        contextDelegate?.onContextReceived(applicationContext: applicationContext)
    }
    
    // ============================================================
    // MARK: User Info - Queue of dicts to send, sent in order even when offline
    // ============================================================
    func sendUserInfo(_ userInfo: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(userInfo, replyHandler: { reply in
                // Optional: Handle reply from iPhone
            }, errorHandler: { error in
                print("Error sending live score: \(error)")
            })
        } else {
            WCSession.default.transferUserInfo(userInfo)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        userInfoDelegate?.onUserInfoReceived(userInfo: userInfo)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        userInfoDelegate?.onUserInfoReceived(userInfo: message)
        replyHandler(["status": "received"])
    }
        
    // ============================================================
    //MARK: Delegate
    // ============================================================
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
