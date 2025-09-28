import SwiftUI
import Playgrounds

@Observable
class Score: Codable {
    
    enum Player : Int, Codable {
        case player1 = 0
        case player2 = 1
    }
    
    struct Result : Codable {
        var player1:Int = 0
        var player2:Int = 0
        
        init(){
            player1 = 0; player2 = 0
        }
        
        init(_ a:Int, _ b:Int){
            player1 = a; player2 = b
        }
        
        init(player1:Int, player2:Int){
            self.player1 = player1; self.player2 = player2
        }
        
        func forPlayer(_ player:Player) -> Int {
            player == .player1 ? player1 : player2
        }
        
        func isValid(_ target:Int = 11) -> Bool {
            let winner = max(player1, player2)
            let loser = min(player1, player2)
            let diff = winner - loser
            
            // Must reach target and win by at least 2
            guard winner >= target, diff >= 2 else { return false }
            
            // If the winner stops exactly at target, any loser <= target - 2 is fine (e.g., 11–0 ... 11–9)
            if winner == target {
                return loser <= target - 2
            }
            
            // Once past target, the game must end immediately upon a 2-point lead:
            // the loser must be exactly winner - 2 (e.g., 12–10, 13–11, 15–13, etc.)
            return loser == winner - 2
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
        if score.player1 + score.player2 >= 20 {
            return Player(rawValue:(history.count + firstServer.rawValue) % 2)!
        }
        return Player(rawValue:(Int(history.count / 2) + firstServer.rawValue) % 2)!
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
        if score.player1 + score.player2 >= 20 {
            return true
        }
        return history.count % 2 == 1
    }
    
    func addScore(player:Player, clearRedo:Bool = true){
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

//#Playground {
  //  Score.Result(10, 12).isValid() // true
//}
