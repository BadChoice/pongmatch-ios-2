import Foundation

struct User : Codable {
    let id:Int
    let name:String
    let elo:Int
    let avatar:String?
    
    var initials:String {
        name.components(separatedBy: .whitespacesAndNewlines) // split by spaces
                    .filter { !$0.isEmpty }                   // remove empty parts
                    .compactMap { $0.first }                  // take first character
                    .map { String($0).uppercased() }          // uppercase
                    .joined()                                 // join into string
    }
    
    static func me() -> User {
        User(
            id:1,
            name:"Jordi Puigdellívol",
            elo:1500,
            avatar:"http://pongmatch.app/storage/avatars/nRw1un6FnI50LoNn.png"
        )
    }
    
    static func unknown() -> User {
        User(
            id: 0,
            name: "Unknown",
            elo: 0,
            avatar: "https://pongmatch.app/img/default-avatar.png"
        )
    }
}
