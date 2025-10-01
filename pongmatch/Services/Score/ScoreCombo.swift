import SwiftUI

enum ScoreCombo : CustomStringConvertible {
    
    case perfect
    case matchPoint11_0
    case gettingTo11_0
    
    case matchPoint
    
    case streak9Points
    case streak7Points
    case streak5Points
    case streak3Points
        
    var description: String {
        switch self {
        case .perfect: "PERFECT!"
        case .matchPoint11_0: "1 Point for 11-0!"
        case .gettingTo11_0: "11-0 coming!"
        case .matchPoint: "Match Point!"
        case .streak9Points: "9 Points Streak"
        case .streak7Points: "7 Points Streak"
        case .streak5Points: "5 Point Streak"
        case .streak3Points: "3 Points Streak"
        }
    }
        
    var color:Color {
        switch self {
        case .perfect: Color.green
        case .matchPoint11_0: Color.red
        case .gettingTo11_0: Color.orange
        case .matchPoint: Color.green
        case .streak9Points: Color.purple
        case .streak7Points: Color.blue
        case .streak5Points: Color.pink
        case .streak3Points: Color.cyan
        }
    }
    
    var font:Font {
        switch self {
        case .perfect: .title.weight(.heavy)
        case .matchPoint11_0: .subheadline.bold()
        case .gettingTo11_0: .subheadline.bold()
        case .matchPoint: .footnote.weight(.heavy)
        case .streak9Points:.footnote.bold()
        case .streak7Points:.footnote.bold()
        case .streak5Points:.footnote.bold()
        case .streak3Points: .footnote.bold()
        }
    }
    
    var intensity: Double {
        switch self {
        case .perfect: 1
        case .matchPoint11_0: 1
        case .gettingTo11_0: 0.8
        case .matchPoint: 0.6
        case .streak9Points: 0.5
        case .streak7Points: 0.4
        case .streak5Points: 0.2
        case .streak3Points: 0.1
        }
    }
    
    static func getCombo(for score:Score, player:Player) -> ScoreCombo? {
        if isPerfectFor(score, player: player)                { return .perfect }
        if isMatchPoint11_0For(score, player: player)         { return .matchPoint11_0 }
        if isGettingTo11_0For(score, player: player)          { return .gettingTo11_0 }
        if isMatchPointFor(score, player: player)             { return .matchPoint }
        if isPointStreakFor(score, player: player, streak: 9) { return .streak9Points }
        if isPointStreakFor(score, player: player, streak: 7) { return .streak7Points }
        if isPointStreakFor(score, player: player, streak: 5) { return .streak5Points }
        if isPointStreakFor(score, player: player, streak: 3) { return .streak3Points }
        return nil
    }
    
    static func isPerfectFor(_ score:Score, player:Player) -> Bool {
        if player == .player1 {
            return score.score.player1 == score.gamePoints && score.score.player2 == 0
        }
        return score.score.player2 == score.gamePoints && score.score.player1 == 0
    }
    
    static func isMatchPointFor(_ score:Score, player:Player) -> Bool {
        if score.winner() != nil { return false }
        
        let target = score.gamePoints - 1
        if player == .player1 {
            return score.score.player1 >= target && score.score.player1 >= score.score.player2 + 1
        }
        return score.score.player2 >= target && score.score.player2 >= score.score.player1 + 1
    }
    
    static func isMatchPoint11_0For(_ score:Score, player:Player) -> Bool {
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
