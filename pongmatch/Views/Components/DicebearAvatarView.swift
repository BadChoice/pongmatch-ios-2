import SwiftUI
import CryptoKit

struct DicebearAvatarView: View {
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
    
    @State private var image: UIImage?
    
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
    
    private var dicebearURL: URL? {
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
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipShape(Circle())
                } else {
                    // Simple placeholder while loading
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.secondary)
                                .padding(geo.size.width * 0.25)
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .id(dicebearURL?.absoluteString ?? UUID().uuidString)
        .task(id: dicebearURL) {
            await MainActor.run { image = nil }
            guard let url = dicebearURL else { return }
            if let downloaded = await Images.download(url) {
                await MainActor.run { image = downloaded }
            }
        }
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

#Preview("Dicebear") {
    
    VStack {
        DicebearAvatarView(email: "jordi+pongmatch@gloobus.net", style: .adventurer)
            .frame(width: 96)
        
        DicebearAvatarView(user: User.me(), style: .botttsNeutral)
            .frame(width: 96)
        
        DicebearAvatarView(user: User.me(), style: .bigSmile)
            .frame(width: 96)
        
        DicebearAvatarView(user: User.me(), style: .thumbs)
            .frame(width: 96)
    }
}

