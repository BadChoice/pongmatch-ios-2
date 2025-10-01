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

//#Playground {
  //  Result(10, 12).isValid() // true
//}

