import SwiftUI

struct GravatarView: View {
    typealias DefaultImage = Gravatar.DefaultImage
    typealias Rating = Gravatar.Rating
    
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
        Gravatar.url(
            email: email,
            size: size,
            defaultImage: defaultImage,
            rating: rating,
            forceDefault: forceDefault
        )
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
}

#Preview("Gravatar") {
    VStack(spacing: 16) {
        GravatarView(email: "jordi+pongmatch@gloobus.net", size: 96, defaultImage: .mp)
            .frame(width: 96)
        
        GravatarView(user: User.me(), size: 96, defaultImage: .identicon)
            .frame(width: 96)
        
        GravatarView(email:"jordi@gloobus.net", size: 96, defaultImage: .identicon)
            .frame(width: 96)
        
        GravatarView(email: "no-gravatar@example.com", size: 96, defaultImage: .identicon)
            .frame(width: 96)
    }
    .padding()
}
