import SwiftUI

struct AvatarView: View {
    
    @State private var image: UIImage?
    let url: String?
    let name: String?
    let winner: Bool
    
    init(user: User, winner: Bool = false) {
        self.url = user.avatar
        self.name = user.initials
        self.winner = winner
    }
    
    init(url: String?, name: String?, winner: Bool = false) {
        self.url = url
        self.name = name
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
        .id(url) // keep identity keyed to the avatar URL
        .task(id: url) {
            // Always clear the previous image when the URL changes or becomes nil
            await MainActor.run { image = nil }
            
            guard let resolvedURL = Images.avatar(url) else { return }
            
            // Load (or fetch from cache) the new image
            if let downloadedImage = await Images.download(resolvedURL) {
                await MainActor.run {
                    image = downloadedImage
                }
            }
        }
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
    AvatarView(
        url: "http://pongmatch.app/storage/avatars/nRw1un6FnI50LoNn.png",
        name: "Jordi Puigdellívol"
    )
}

#Preview {
    AvatarView(
        url: nil,
        name: "Jordi Puigdellívol"
    )
}

#Preview {
    AvatarView(
        url: "http://google.com/not found.png",
        name: "Jordi Puigdellívol"
    )
}

#Preview {
    AvatarView(
        user: User.me(),
        winner: true
    )
}

