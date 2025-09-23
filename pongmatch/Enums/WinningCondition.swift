enum WinningCondition : String, Codable, CaseIterable, CustomStringConvertible {
    case single  = "single"
    case bestof3 = "bestof3"
    case bestof5 = "bestof5"
    case bestof7 = "bestof7"
    
    var matches:Int {
        switch self {
        case .single : 1
        case .bestof3 : 3
        case .bestof5 : 5
        case .bestof7 : 7
        }
    }

    var setsToWin:Int {
        switch self {
        case .single  : 1
        case .bestof3 : 2
        case .bestof5 : 3
        case .bestof7 : 4
        }
    }


    var estimatedPlayingMinutes:Int
    {
        switch self {
        case .single  : 5
        case .bestof3 : 10
        case .bestof5 : 15
        case .bestof7 : 20
        }
    }
    
    var description: String {
        switch self {
            case .single : "Single game"
            case .bestof3 : "Best of 3"
            case .bestof5 : "Best of 5"
            case .bestof7 : "Best of 7"
        }
    }
    
    // A short help text explaining the selected condition.
    var help: String {
        let base = "First to \(setsToWin) set\(setsToWin == 1 ? "" : "s") wins."
        let estimate = "Estimated \(estimatedPlayingMinutes) min."
        
        return switch self {
        case .single: "Play a single game. \(base) \(estimate)"
        case .bestof3, .bestof5, .bestof7: "\(description): \(base) \(estimate)"
        }
    }
    
    static var title:String {
        "Winning condition"
    }
    
    static var icon:String {
        "medal.fill"
    }
}
