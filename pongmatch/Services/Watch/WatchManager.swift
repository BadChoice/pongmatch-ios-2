import Foundation
import WatchConnectivity

protocol WatchContextDelegate {
    func onContextReceived(applicationContext: [String : Any])
}

class WatchManager : NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    
    var contextDelegate:WatchContextDelegate?
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    
    // MARK: Context - Live sync when updated - just one state
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
    
    // MARK: User Info - Queue of dicts to send, sent in order even when offline
    
    
    
    //MARK: Delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
}
