import Foundation
import CryptoKit

class Dicebear {
    enum Style: String {
        case adventurer
        case identicon
        case thumbs
        case bottts
        //case initials //
        case botttsNeutral = "bottts-neutral"
        case pixelArt = "pixel-art"
        case bigSmile = "big-smile"
    }
    
    let email: String?
    let style: Style
    let apiSize: Int // pixel size requested from Dicebear API
    
    init(user: User, style: Style = .adventurer, apiSize: Int = 256) {
        self.email = user.email
        self.style = style
        self.apiSize = apiSize
    }
    
    init(email: String?, style: Style = .adventurer, apiSize: Int = 256) {
        self.email = email
        self.style = style
        self.apiSize = apiSize
    }
    
    var url: URL? {
        guard let seed = Self.seed(from: email) else { return nil }
        var components = URLComponents(string: "https://api.dicebear.com/7.x/\(style.rawValue)/png")
        components?.queryItems = [
            URLQueryItem(name: "seed", value: seed),
            URLQueryItem(name: "size", value: "\(apiSize)"),
            // Optional cosmetics
            URLQueryItem(name: "backgroundType", value: "gradientLinear"),
            URLQueryItem(name: "backgroundColor", value: "b6e3f4,c0aede,d1d4f9")
        ]
        return components?.url
    }
    
    private static func seed(from email: String?) -> String? {
        guard let raw = email?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(),
              !raw.isEmpty
        else { return nil }
        
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
