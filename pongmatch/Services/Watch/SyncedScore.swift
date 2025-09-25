import Foundation
import Combine
import SwiftUI

class SyncedScore: NSObject, ObservableObject, WatchContextDelegate {
    static let shared = SyncedScore()
    
    @Published var score:Score!
    
    override private init() {
        super.init()
        WatchManager.shared.contextDelegate = self
    }
    
    func retrieve() -> Score? {
        fromContext(WatchManager.shared.getContext())
    }
    
    // Send to other side
    func sync() {
        guard let data = try? JSONEncoder().encode(score) else {
            return
        }
        WatchManager.shared.updateContext(["score" : data])
    }
    
    func replace(score:Score){
        DispatchQueue.main.async {
            withAnimation {
                self.score = score
            }
        }
    }
        
    func clear(){
        score = nil
        WatchManager.shared.removeFromContext("score")
    }
    
    
    func onContextReceived(applicationContext: [String : Any]) {
        guard let score = fromContext(applicationContext) else { return }
        
        DispatchQueue.main.async {
            withAnimation {
                self.score = score
            }
        }
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
        
}
