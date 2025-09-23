import Foundation
import Combine
import WatchConnectivity
import SwiftUI

class SyncedScore: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = SyncedScore()
    
    @Published var score:Score!
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func retrieve() -> Score? {
        fromContext(WCSession.default.receivedApplicationContext)
    }
    
    // Send to other side
    func sync() {
        guard WCSession.isSupported() else { return }
        guard let data = try? JSONEncoder().encode(score) else {
            return
        }
        try? WCSession.default.updateApplicationContext(["score" : data])
    }
    
    func replace(score:Score){
        DispatchQueue.main.async {
            withAnimation {
                self.score = score
            }
        }
    }
    
    #if os(watchOS)
    func finishedOnWatch() {
        guard let data = try? JSONEncoder().encode(score) else {
            return
        }
    
        //WCSession.default.transferUserInfo(["upload_score": data])  // Background transfer
        WCSession.default.transferUserInfo(["ping": "hello"])

    }
    #endif
    
    func clear(){
        score = nil
        guard WCSession.isSupported() else { return }
        var context = WCSession.default.receivedApplicationContext
        context.removeValue(forKey: "score") // remove the key
        try? WCSession.default.updateApplicationContext(context)
    }
    
    
    // Receive app context from other side (synced scoreboard)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let score = fromContext(applicationContext) else { return }
        
        DispatchQueue.main.async {
            withAnimation {
                self.score = score
            }
        }
    }
    
    //Receive userinfo
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        guard let data = userInfo["upload_score"] as? Data else { return }
        guard let score = try? JSONDecoder().decode(Score.self, from: data) else { return }
        
        var gamesToUpload:[Score] = Storage().get(.gamesFinishedOnWatch) ?? []
        gamesToUpload.append(score)
        Storage().save(.gamesFinishedOnWatch, value: gamesToUpload)
    }

    
    private func fromContext(_ context: [String: Any]) -> Score? {
        guard let data = context["score"] as? Data else {
            return nil
        }
        guard let score = try? JSONDecoder().decode(Score.self, from: data) else {
            return nil
        }
        
        return score
    }
    
    // MARK: - Session delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
}
