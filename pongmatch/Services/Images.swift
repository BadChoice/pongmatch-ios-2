import Foundation

struct Images {
    
    static func avatar(_ avatar:String?) -> URL? {
        guard let avatar else { return nil }
        if avatar.hasPrefix("http") { return URL(string: avatar) }
        
        return URL(string: "\(Pongmatch.url)/storage/avatars/\(avatar)")
    }
}
