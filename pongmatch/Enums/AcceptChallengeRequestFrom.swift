enum AcceptChallengeRequestFrom: String, Codable, CaseIterable, CustomStringConvertible {
    case nobody = "nobody"
    case following = "following"
    case followers = "followers"
    case everybody = "everybody"
    
    var description: String {
        switch self {
        case .nobody: "Nobody"
        case .following: "Following"
        case .followers: "Followers"
        case .everybody: "Everybody"
        }
    }
}
