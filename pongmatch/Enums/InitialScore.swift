enum InitialScore : String, Codable, CaseIterable, CustomStringConvertible {
    case standard = "standard"
    case fair     = "fair"
    
    var description: String {
        switch self {
        case .standard: "Standard"
        case .fair: "Fair"
        }
    }
    
    // A short help text explaining what the selected option means.
    var help: String {
        switch self {
        case .standard: "Both players start at 0–0."
        case .fair: "Adjusts the starting points to help balance the match between players of different skill levels."
        }
    }
    
    var icon: String {
        switch self {
        case .standard: "00.circle.fill"
        case .fair: "50.circle.fill" //scalemass.fill"
        }
    }
    
    var eloConstant:Int {
        switch self {
        case .standard: 32
        case .fair: 16
        }
    }
    
    
    static var title:String {
        "Initial Score"
    }
    
    static var icon:String {
        "bird.fill"
    }
    
    func initialResult(for player1:User?, player2:User?) -> Score.Result
    {
        if self == .standard {
            return Score.Result()
        }
        
        guard let player1, let player2 else {
            return Score.Result()
        }

        let pointsDifference = abs(player1.ranking - player2.ranking)
        let initialPoints = initialPointsFor(difference: abs(pointsDifference))
        return pointsDifference > 0 ? Score.Result(0, initialPoints) : Score.Result(initialPoints, 0)
    }
    
    private func initialPointsFor(difference:Int) -> Int {
        if difference < 50  { return 0 }
        if difference < 100 { return 1 }
        if difference < 150 { return 2 }
        if difference < 200 { return 3 }
        if difference < 250 { return 4 }
        if difference < 300 { return 5 }
        if difference < 350 { return 6 }
        if difference < 400 { return 7 }
        if difference < 450 { return 8 }
        if difference < 500 { return 9 }
        return 10
    }
    
}
