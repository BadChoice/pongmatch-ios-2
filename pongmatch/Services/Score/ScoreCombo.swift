import SwiftUI

enum ScoreCombo : CustomStringConvertible {
    
    case perfect
    case perfectMatchPoint
    case roadToPerfect
    
    case matchPoint
    
    case pointsStreak(_ streak: Int)

        
    var description: String {
        switch self {
        case .perfect: "PERFECT!"
        case .perfectMatchPoint: "1 Point for PERFECT!"
        case .roadToPerfect: "Perfect's coming..."
        case .matchPoint: "Match Point!"
        case .pointsStreak(_): "Points Streak"
        }
    }
    
        
    var color:Color {
        switch self {
        case .perfect: Color.green
        case .perfectMatchPoint: Color.red
        case .roadToPerfect: Color.orange
        case .matchPoint: Color.green
        case .pointsStreak(let streak) where streak >= 9: Color.purple
        case .pointsStreak(let streak) where streak >= 7: Color.blue
        case .pointsStreak(let streak) where streak >= 5: Color.pink
        case .pointsStreak(_) : Color.cyan
        }
    }
    
    var font:Font {
        switch self {
        case .perfect: .title2.weight(.heavy)
        case .perfectMatchPoint: .title2.weight(.heavy)
        case .roadToPerfect: .title2.bold()
        case .matchPoint: .title2.weight(.heavy)
        case .pointsStreak(_) : .footnote.weight(.heavy)
        }
    }
    
    var flameSpeed: Double {
        switch self {
        case .perfect: 1
        case .perfectMatchPoint: 1
        case .roadToPerfect: 0.8
        case .matchPoint: 0.6
        case .pointsStreak(let streak) where streak >= 9: 0.5
        case .pointsStreak(let streak) where streak >= 7: 0.4
        case .pointsStreak(let streak) where streak >= 5: 0.2
        case .pointsStreak(_) : 0.1
        }
    }
    
    var shakeIntensity: Double {
        switch self {
        case .perfect: 1
        case .perfectMatchPoint: 1
        case .roadToPerfect: 0.8
        case .matchPoint: 0.2
        case .pointsStreak(let streak) where streak >= 9: 0.5
        case .pointsStreak(let streak) where streak >= 7: 0.3
        case .pointsStreak(let streak) where streak >= 5: 0.1
        case .pointsStreak(_) : 0
        }
    }
    
    static func getCombo(for score:Score, player:Player) -> ScoreCombo? {
        if isPerfectFor(score, player: player)                { return .perfect }
        if isPerfectMatchPoint(score, player: player)         { return .perfectMatchPoint }
        if isRoadToPerfectFor(score, player: player)       { return .roadToPerfect }
        if isMatchPointFor(score, player: player)             { return .matchPoint }
        if let streak = getPointStreak(for: score, player: player) {
            return .pointsStreak(streak)
        }
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
    
    static func isPerfectMatchPoint(_ score:Score, player:Player) -> Bool {
        guard score.history.count == 10 else { return false }
        return score.history.allSatisfy { $0 == player }
    }
    
    static func getPointStreak(for score:Score, player:Player) -> Int? {
        if score.history.count < 3 { return nil }
        for streak in (3...score.history.count).reversed() {
            if isPointStreakFor(score, player: player, streak: streak) {
                return streak
            }
        }
        return nil
    }
    
    static func isPointStreakFor(_ score:Score, player:Player, streak:Int) -> Bool {
        if score.history.count < streak { return false }
        return score.history.suffix(streak).allSatisfy { $0 == player }
    }
    
    static func isRoadToPerfectFor(_ score:Score, player:Player) -> Bool {
        if score.history.count < 8 { return false }
        return score.history.allSatisfy { $0 == player }
    }
        
}
