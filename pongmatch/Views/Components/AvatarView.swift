import SwiftUI

struct AvatarView: View {
    
    @State private var image: UIImage?
    let url: String?
    let name: String?
    
    init(user: User) {
        self.url = user.avatar
        self.name = user.initials
    }
    
    init(url: String?, name: String?) {
        self.url = url
        self.name = name
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
                            .font(.system(size: geo.size.width * 0.4, weight: .bold)) // 👈 scales font to fit
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .aspectRatio(1, contentMode: .fit) // Ensures it stays square
        .id(url)
        .task(id: url) {
            Task.detached {
                if let url = await Images.avatar(url), let downloadedImage = await Images.download(url) {
                    await MainActor.run {
                        image = downloadedImage
                    }
                }
            }
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


