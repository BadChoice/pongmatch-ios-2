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
    
    static var title:String {
        "Initial Score"
    }
    
    static var icon:String {
        "bird.fill"
    }
    
}
