import Foundation

struct SyncGames {
    
    static func gameFinished(_ game:Game, sets:[Result]){
        game.results = sets.map {
            [$0.player1, $0.player2]
        }
        game.status = .finished
        guard let data = try? JSONEncoder().encode(game) else { return }
        
        WatchManager.shared.sendUserInfo([
            "game" : data,
        ])
    }
}
