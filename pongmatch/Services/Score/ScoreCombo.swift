enum ScoreCombo : CustomStringConvertible {
    
    case streak3Points
    case streak5Points
    case streak7Points
    
    case gettingTo11_0
    case matchPoint11_0
    
    case matchPoint
    
    var description: String {
        switch self {
        case .streak3Points: "3 points streak"
        case .streak5Points: "5 point streak"
        case .streak7Points: "7 points streak"
        case .gettingTo11_0: "11-0 is coming!"
        case .matchPoint11_0: "1 Point for 11-0!"
        case .matchPoint: "Match Point!"
        }
    }
    
    static func getCombo(for score:Score, player:Player) -> ScoreCombo? {
        if isMatchPoint11_0For(score, player: player)         { return .matchPoint11_0 }
        if isGettingTo11_0For(score, player: player)          { return .gettingTo11_0 }
        if isPointStreakFor(score, player: player, streak: 7) { return .streak7Points }
        if isPointStreakFor(score, player: player, streak: 5) { return .streak5Points }
        if isPointStreakFor(score, player: player, streak: 3) { return .streak3Points }
        if isMatchPointFor(score, player: player)             { return .matchPoint }
        return nil
    }
    
    static func isMatchPointFor(_ score:Score, player:Player) -> Bool {
        let target = score.gamePoints - 1
        if player == .player1 {
            return score.score.player1 >= target && score.score.player1 >= score.score.player2 + 1
        }
        return score.score.player2 >= target && score.score.player2 >= score.score.player1 + 1
    }
    
    static func isMatchPoint11_0For(_ score:Score, player:Player) -> Bool {
        print(score.history.count)
        guard score.history.count == 10 else { return false }
        return score.history.allSatisfy { $0 == player }
    }
    
    static func isPointStreakFor(_ score:Score, player:Player, streak:Int) -> Bool {
        if score.history.count < streak { return false }
        return score.history.suffix(streak).allSatisfy { $0 == player }
    }
    
    static func isGettingTo11_0For(_ score:Score, player:Player) -> Bool {
        if score.history.count < 8 { return false }
        return score.history.allSatisfy { $0 == player }
    }
        
}
