import Foundation



struct User : Codable {
    let id:Int
    let name:String
    let username:String
    let email:String
    let ranking:Int
    let avatar:String?
    
    let games_won:Int?
    let games_lost:Int?
    let last_match_date:Date?
    
    var global_ranking:Int?
    
    var initials:String {
        name.components(separatedBy: .whitespacesAndNewlines) // split by spaces
                    .filter { !$0.isEmpty }                   // remove empty parts
                    .compactMap { $0.first }                  // take first character
                    .map { String($0).uppercased() }          // uppercase
                    .joined()                                 // join into string
    }
    
    var language: String?
    var phone: String?
    var address: String?
    var accept_challenge_requests_from: AcceptChallengeRequestFrom?
    
    // MARK: Factory
    static func me() -> User {
        User(
            id:1,
            name:"Jordi Puigdellívol",
            username:"badchoide",
            email:"jordi+pongmatch@gloobus.net",
            ranking:1500,
            avatar:"http://pongmatch.app/storage/avatars/nRw1un6FnI50LoNn.png",
            games_won: 102,
            games_lost: 53,
            last_match_date: Date(),
            language: nil,
            phone: nil,
            address: nil,
            accept_challenge_requests_from: nil
        )
    }
    
    static func unknown() -> User {
        User(
            id: 0,
            name: "Unknown",
            username:"unknown",
            email: "unknown@codepassion.io",
            ranking: 0,
            avatar: "https://pongmatch.app/img/default-avatar.png",
            games_won: nil,
            games_lost: nil,
            last_match_date: nil,
            language: nil,
            phone: nil,
            address: nil,
            accept_challenge_requests_from: nil
        )
    }
}
