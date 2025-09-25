import Foundation
import Combine
import SwiftUI

class WatchFinishedGames: ObservableObject, WatchUserInfoDelegate {
    
    @Published var games:[Game] = Storage().getGames(.gamesFinishedOnWatch)
    
    init() {
        WatchManager.shared.userInfoDelegate = self
    }
    
    func onUserInfoReceived(userInfo: [String : Any]) {
        guard let game = fromUserInfo(userInfo) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            withAnimation {
                self.games.append(game)
            }
            Storage().saveGames(.gamesFinishedOnWatch, games: self.games)
        }
    }
        
    private func fromUserInfo(_ userInfo: [String: Any]) -> Game? {
        guard let data = userInfo["game"] as? Data else {
            return nil
        }
        guard let score = try? JSONDecoder().decode(Game.self, from: data) else {
            return nil
        }
        
        return score
    }
        
}
