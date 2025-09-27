import SwiftUI
import CryptoKit

struct GravatarAvatarView: View {
    enum DefaultImage: String {
        case mp
        case identicon
        case monsterid
        case wavatar
        case retro
        case robohash
        case blank
        case _404 = "404"
    }
    
    enum Rating: String {
        case g, pg, r, x
    }
    
    @State private var image: UIImage?
    
    let email: String?
    let size: Int
    let defaultImage: DefaultImage
    let rating: Rating
    let forceDefault: Bool
    
    init(
        user: User,
        size: Int = 256,
        defaultImage: DefaultImage = .mp,
        rating: Rating = .g,
        forceDefault: Bool = false
    ) {
        self.email = user.email
        self.size = size
        self.defaultImage = defaultImage
        self.rating = rating
        self.forceDefault = forceDefault
    }
    
    init(
        email: String?,
        size: Int = 256,
        defaultImage: DefaultImage = .mp,
        rating: Rating = .g,
        forceDefault: Bool = false
    ) {
        self.email = email
        self.size = size
        self.defaultImage = defaultImage
        self.rating = rating
        self.forceDefault = forceDefault
    }
    
    private var gravatarURL: URL? {
        guard let hash = Self.md5(from: email) else { return nil }
        let clampedSize = max(1, min(size, 2048))
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.gravatar.com"
        components.path = "/avatar/\(hash)"
        var items = [
            URLQueryItem(name: "s", value: "\(clampedSize)"),
            URLQueryItem(name: "d", value: defaultImage.rawValue),
            URLQueryItem(name: "r", value: rating.rawValue)
        ]
        if forceDefault {
            items.append(URLQueryItem(name: "f", value: "y"))
        }
        components.queryItems = items
        return components.url
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
        .id(gravatarURL?.absoluteString ?? UUID().uuidString)
        .task(id: gravatarURL) {
            await MainActor.run { image = nil }
            guard let url = gravatarURL else { return }
            if let downloaded = await Images.download(url) {
                await MainActor.run { image = downloaded }
            }
        }
    }
    
    private static func md5(from email: String?) -> String? {
        guard let raw = email?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(),
              !raw.isEmpty
        else { return nil }
        
        let digest = Insecure.MD5.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

#Preview("Gravatar") {
    VStack(spacing: 16) {
        GravatarAvatarView(email: "jordi+pongmatch@gloobus.net", size: 96, defaultImage: .mp)
            .frame(width: 96)
        
        GravatarAvatarView(user: User.me(), size: 96, defaultImage: .identicon)
            .frame(width: 96)
        
        GravatarAvatarView(email:"jordi@gloobus.net", size: 96, defaultImage: .identicon)
            .frame(width: 96)
        
        GravatarAvatarView(email: "no-gravatar@example.com", size: 96, defaultImage: .identicon)
            .frame(width: 96)
    }
    .padding()
}
