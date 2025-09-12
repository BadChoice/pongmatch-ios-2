import SwiftUI

@Observable
class Score: Codable {
    
    enum Player : Int, Codable {
        case player1 = 0
        case player2 = 1
    }
    
    struct Result : Codable {
        var player1:Int = 0
        var player2:Int = 0
        
        func forPlayer(_ player:Player) -> Int {
            player == .player1 ? player1 : player2
        }
        
        func lead() -> Player?{
            if player1 > player2 { return .player2 }
            if player2 > player1 { return .player1 }
            return nil
        }
    }
    
    var started_at = Date()
    var ended_at:Date? = nil
    
    let game:Game
        
    var score:Result = Result()
    var sets:[Result]  = []
    
    var gamePoints:Int = 11
    
    private var firstServer:Player
    
    var history:[Player] = []
    var redoHistory:[Player] = []

    init(game:Game) {
        self.game = game
        self.firstServer = Player(rawValue: .random(in: 0...1))!
    }
    
    var player1:User { game.player1 }
    var player2:User { game.player2 }
    
    
    func player(_ player:Player) -> User {
        player == .player1 ? player1 : player2
    }
    
    var server:Player {
        Player(rawValue:(Int(history.count / 2) + firstServer.rawValue) % 2)!
    }
        
    func isMatchPointFor(player:Player) -> Bool {
        if player == .player1 {
            return score.player1 >= 10 && score.player1 >= score.player2 + 1
        }
        return score.player2 >= 10 && score.player2 >= score.player1 + 1
    }
    
    func winner() -> User? {
        if score.player1 >= 11 && score.player1 >= score.player2 + 2 {
            return player1
        }
        
        if score.player2 >= 11 && score.player2 >= score.player1 + 2 {
            return player2
        }
        return nil
    }
    
    func matchWinner() -> User?{
        guard winner() != nil else { return nil }
        
        if setsResult.player1 == game.winning_condition.setsToWin {
            return player1
        }
        
        if setsResult.player2 == game.winning_condition.setsToWin {
            return player2
        }
        
        return nil
    }
    
    
    func setsResult(for player:Player) -> Int {
        player == .player1 ? setsResult.player1 : setsResult.player2
    }
    /**
     The total result in sets
     */
    var setsResult:Result {
        var result = Result()
        sets.forEach { set in
            if set.player1 > set.player2 { result.player1 += 1}
            else                         { result.player2 += 1}
        }
        return result
    }
        
    var isSecondServe: Bool {
        history.count % 2 == 1
    }
    
    func addScore(player:Player, clearRedo:Bool = false){
        guard winner() == nil else { return }
        
        history.append(player)
        if clearRedo {
            redoHistory = []
        }
        
        if player == .player1 {
            score.player1 += 1
        } else {
            score.player2 += 1
        }
    }
    
    func startNext(){
        sets.append(score)
        
        if setsResult.player1 == game.winning_condition.setsToWin || setsResult.player2 == game.winning_condition.setsToWin {
            return gameFinished()
        }
        
        score       = Result()
        firstServer = Player(rawValue:(firstServer.rawValue + 1) % 2)!
        history     = []
    }
    
    func gameFinished(){
        ended_at = Date()
    }
        
    func undo(){
        guard history.count > 0 else { return }
        redoHistory.append(history.popLast()!)
        if redoHistory.last == .player1 {
            score.player1 -= 1
        } else {
            score.player2 -= 1
        }
    }
    
    func redo(){
        guard redoHistory.count > 0 else { return }
        let player = redoHistory.popLast()!
        addScore(player: player, clearRedo: false)
    }
    
    func reset(){
        sets = []
        score = Result()
        history = []
        redoHistory = []
        firstServer = Player(rawValue: Int.random(in: 0...1))!
    }
}
