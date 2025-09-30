import SwiftUI

struct AvatarView: View {
    
    @State private var image: UIImage?
    
    let url: String?
    let name: String?
    let email: String?
    let winner: Bool
    
    init(user: User, winner: Bool = false) {
        self.url = user.avatar
        self.name = user.initials
        self.email = user.email
        self.winner = winner
    }
    
    init(url: String?, name: String?, email: String? = nil, winner: Bool = false) {
        self.url = url
        self.name = name
        self.email = email
        self.winner = winner
    }
    
    var body: some View {
        GeometryReader { geo in
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(.gray)
                    if let name {
                        Text(name.prefix(2).uppercased())
                            .font(.system(size: geo.size.width * 0.4, weight: .bold))
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            if winner {
               Circle()
                   .stroke(Color.green, lineWidth: geo.size.width * 0.04)
                   .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            if winner {
                WinnerIconView()
            }
        }
        // Keep identity keyed to both avatar URL and email (so we refetch if email changes)
        .id(identityKey)
        .task(id: identityKey) {
            // Reset state whenever the URL or email changes
            await MainActor.run {
                image = nil
            }
            
            // 1) Try custom avatar URL if present
            if let customURL = Images.avatar(url) {
                if let downloadedImage = await Images.download(customURL) {
                    await MainActor.run { image = downloadedImage }
                    return
                }
            }
            
            // 2) Try Gravatar with d=404 so we can detect absence
            if let downloadedImage = await Gravatar.fetch(email: email) {
                await MainActor.run {
                    image = downloadedImage
                }
            }
        }
    }
    
    // Combine url+email to force refresh when either changes
    private var identityKey: String {
        "\(url ?? "nil")|\(email ?? "nil")"
    }
}


struct WinnerIconView : View {
    var body: some View {
        GeometryReader { geo in
            let crownSize = geo.size.width * 0.28
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .padding(crownSize * 0.15)
                .frame(width: crownSize, height: crownSize)
                .foregroundStyle(.black)
                .background(.yellow)
                .clipShape(Circle())
                .position(
                    x: geo.size.width - crownSize / 2,
                    y: crownSize / 2
                )
        }
    }
}

#Preview {
    VStack {
        
        AvatarView(
            url: "http://pongmatch.app/storage/avatars/nRw1un6FnI50LoNn.png",
            name: "Jordi Puigdellívol",
            email: "jordi+pongmatch@gloobus.net"
        )
        
        AvatarView(
            url: nil,
            name: "Jordi Puigdellívol",
            email: "jordi@gloobus.net"
        )
        
        AvatarView(
            url: "http://google.com/not found.png",
            name: "Jordi Puigdellívol",
            email: "jordi+pongmatch@gloobus.net"
        )
        
        AvatarView(
            user: User.me(),
            winner: true
        )
        
        AvatarView(
            user:User.unknown()
        )
    }
}
