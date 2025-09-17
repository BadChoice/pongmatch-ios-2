import Foundation



struct User : Codable {
    let id:Int
    let name:String
    let username:String
    let email:String
    let ranking:Int
    let avatar:String?
    let language:Language
    
    let games_won:Int?
    let games_lost:Int?
    let last_match_date:Date?
    
    var deepDetails:UserDeepDetails?
    var friendship:FriendshipStatus?
    
    var initials:String {
        name.components(separatedBy: .whitespacesAndNewlines) // split by spaces
                    .filter { !$0.isEmpty }                   // remove empty parts
                    .compactMap { $0.first }                  // take first character
                    .map { String($0).uppercased() }          // uppercase
                    .joined()                                 // join into string
    }
    
    var phone_prefix: String?
    var phone: String?
    var address: String?
    var accept_challenge_requests_from: AcceptChallengeRequestFrom?
    
    func canBeChallengedByMe() -> Bool {
        guard let accept_challenge_requests_from else { return false }
        
        return switch accept_challenge_requests_from {
        case .nobody: false
        case .following: friendship?.followsMe ?? false
        case .followers: friendship?.isFollowed ?? false
        case .everybody: true
        }
    }
    
    // MARK: Factory
    static func me() -> User {
        User(
            id:1,
            name:"Jordi Puigdellívol",
            username:"badchoide",
            email:"jordi+pongmatch@gloobus.net",
            ranking:1500,
            avatar:"http://pongmatch.app/storage/avatars/nRw1un6FnI50LoNn.png",
            language: .english,
            games_won: 102,
            games_lost: 53,
            last_match_date: Date(),
            friendship: FriendshipStatus(isFollowed: false, followsMe: false),
            phone_prefix: nil,
            phone: nil,
            address: nil,
            accept_challenge_requests_from: .everybody,
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
            language: .english,
            games_won: nil,
            games_lost: nil,
            last_match_date: nil,
            friendship: FriendshipStatus(isFollowed: false, followsMe: false),
            phone_prefix: nil,
            phone: nil,
            address: nil,
            accept_challenge_requests_from: .everybody
        )
    }
}


struct FriendshipStatus:Codable {
    let isFollowed:Bool
    let followsMe:Bool
}

struct UserDeepDetails:Codable{
    let global_ranking:Int
    let followers:Int
    let following:Int
}
