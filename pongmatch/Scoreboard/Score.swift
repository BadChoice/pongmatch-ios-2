import SwiftUI

@Observable
class Score {
    let players:[User]
    
    var score:(Int, Int) = (0, 0)
    var sets:[(Int, Int)]  = []
    
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
        score.0 >= 10 && score.0 >= score.1 + 1
    }
    
    var isMatchPointForPlayer2:Bool {
        score.1 >= 10 && score.1 >= score.0 + 1
    }
    
    func winner() -> User? {
        if score.0 >= 11 && score.0 >= score.1 + 2 {
            return player1
        }
        
        if score.1 >= 11 && score.1 >= score.0 + 2 {
            return player2
        }
        return nil
    }
    
    /**
     The total result in sets
     */
    var setsResult:(Int,Int){
        var result = (0, 0)
        sets.forEach { a, b in
            if a > b { result.0 += 1}
            else     { result.1 += 1}
        }
        return result
    }
        
    var isSecondServe: Bool {
        history.count % 2 == 1
    }
    
    func addScore(player:Int){
        guard winner() == nil else { return }
        
        history.append(player)
        
        if player == 0 {
            score.0 += 1
        } else {
            score.1 += 1
        }
    }
    
    func startNext(){
        sets.append(score)
        score       = (0, 0)
        firstServer = (firstServer + 1) % 2
        history     = []
    }
        
    func undo(){
        guard history.count > 0 else { return }
        if history.popLast() == 0 {
            score.0 -= 1
        } else {
            score.1 -= 1
        }
    }
    
    func reset(){
        sets = []
        score = (0, 0)
        history = []
        firstServer = Int.random(in: 0...1)
    }
}
