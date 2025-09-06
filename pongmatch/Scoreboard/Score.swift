import SwiftUI

@Observable
class Score {
    let players:[User]
    
    var player1Score:Int = 0
    var player2Score:Int = 0
    
    let gamePoints:Int = 11
    private var firstServer:Int = 0
    
    init(player1:User, player2:User) {
        self.players = [player1, player2]
        self.firstServer = Int.random(in: 0...1)
    }
    
    var history:[Int] = []
    
    var player1:User { players.first! }
    var player2:User { players.last! }
    
    var server:Int {
        (Int(history.count / 2) + firstServer) % 2
    }
    
    var isMatchPointForPlayer1:Bool {
        player1Score >= 10 && player1Score >= player2Score + 1
    }
    
    var isMatchPointForPlayer2:Bool {
        player2Score >= 10 && player2Score >= player1Score + 1
    }
    
    func winner() -> User? {
        if player1Score >= 11 && player1Score >= player2Score + 2 {
            return player1
        }
        
        if player2Score >= 11 && player2Score >= player1Score + 2 {
            return player2
        }
        
        return nil
    }
        
    var isSecondServe: Bool {
        history.count % 2 == 1
    }
    
    func addScore(player:Int){
        guard winner() == nil else { return }
        
        history.append(player)
        
        if player == 0 {
            player1Score += 1
        } else {
            player2Score += 1
        }
    }
        
    func undo(){
        guard history.count > 0 else { return }
        if history.popLast() == 0 {
            player1Score -= 1
        } else {
            player2Score -= 1
        }
    }
}
