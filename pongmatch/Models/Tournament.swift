import Foundation

struct Tournament : Codable {
    let id:Int
    let name:String
    let information:String?
    let token:String?

    let initial_score:InitialScore
    let ranking_type:RankingType
    let winning_condition:WinningCondition

    let status:LeagueStatus
    let photo:String?
    let date:Date?

    let entry_max_players_slots:Int?
    let entry_min_elo:Int?
    let entry_max_elo:Int?
    let players_count:Int
    
    let user:User?
    let winner:User?
    let location:Location?

    let created_at:Date
    let updated_at:Date
    
    var photoUrl:URL? {
        Images.url(photo, folder: .tournaments)
    }
    
    var shareURL:URL? {
        guard let token else { return nil }
        return URL(string: Pongmatch.url + "tournaments/join/\(token)")
    }
    
    static func fake() -> Tournament {
        Tournament(
            id: 1,
            name: "Primer torunament",
            information: nil,
            token: "ABCDEF",
            initial_score: .standard,
            ranking_type: .competitive,
            winning_condition: .single,
            status: .started,
            photo: nil,
            date: Date(),
            entry_max_players_slots: 100,
            entry_min_elo: 1400,
            entry_max_elo: 1800,
            players_count: 12,
            user: User.me(),
            winner: User.opponent(),
            location: nil,
            created_at: Date(),
            updated_at: Date()
        )
    }
}
