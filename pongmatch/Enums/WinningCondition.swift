enum WinningCondition : String, Codable, CaseIterable {
    case single = "single"
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
}
