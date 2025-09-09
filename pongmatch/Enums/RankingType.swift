enum RankingType : String, Codable, CaseIterable, CustomStringConvertible {
    case competitive = "competitive"
    case friendly = "friendly"
    
    var description: String {
        switch self {
        case .competitive: "Competitive"
        case .friendly: "Friendly"
        }
    }
}
