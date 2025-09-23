enum RankingType : String, Codable, CaseIterable, CustomStringConvertible {
    case competitive = "competitive"
    case friendly = "friendly"
    
    var description: String {
        switch self {
        case .competitive: "Competitive"
        case .friendly: "Friendly"
        }
    }
    
    // A short help text explaining how this affects ranking.
    var help: String {
        switch self {
        case .competitive: "Competitive matches affect your ranking and statistics."
        case .friendly: "Friendly matches are casual and do not affect your ranking."
        }
    }
    
    static var title:String {
        "Ranking type"
    }
    
    static var icon:String {
        "trophy.fill"
    }
}
