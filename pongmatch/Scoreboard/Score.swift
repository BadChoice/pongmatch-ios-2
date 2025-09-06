import SwiftUI

@Observable
class Score {
    let players:[User]
    
    var player1Score:Int = 0
    var player2Score:Int = 0
    
    let gamePoints:Int = 11
    var serving:Int = 0
    
    init(player1:User, player2:User) {
        self.players = [player1, player2]
        self.serving = Int.random(in: 0...1)
    }
    
    var history:[Int] = []
    
    var player1:User { players.first! }
    var player2:User { players.last! }
    
    func score(player:Int){
        history.append(player)
        if player == 0 {
            player1Score += 1
        } else {
            player2Score += 1
        }
        
        if history.count % 2 == 0 {
            changeServer()
        }
    }
    
    private func changeServer(){
        serving = (serving + 1) % 2
    }
    
    var isSecondServe: Bool {
        history.count % 2 == 1
    }
}
