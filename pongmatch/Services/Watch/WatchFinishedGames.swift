import Foundation
import Combine
import SwiftUI

class WatchFinishedGames: ObservableObject, WatchUserInfoDelegate {
    
    static let shared:WatchFinishedGames = WatchFinishedGames()
    
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
            persis()
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
    
    func remove(game:Game) {
        games = games.filter {
            $0.id != game.id
        }
        persis()
    }
    
    private func persis(){
        Storage().saveGames(.gamesFinishedOnWatch, games: self.games)
    }
    
        
}
