enum AcceptChallengeRequestFrom: String, Codable, CaseIterable {
    case nobody = "nobody"
    case following = "following"
    case followers = "followers"
    case everybody = "everybody"
}
