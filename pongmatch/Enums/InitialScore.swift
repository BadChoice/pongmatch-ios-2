enum InitialScore : String, Codable, CaseIterable, CustomStringConvertible {
    case standard = "standard"
    case fair     = "fair"
    
    var description: String {
        switch self {
        case .standard: "Standard"
        case .fair: "Fair"
        }
    }
    
    static var title:String {
        "Initial Score"
    }
    
    static var icon:String {
        "bird.fill"
    }
    
}
