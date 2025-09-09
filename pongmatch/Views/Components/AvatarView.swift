import SwiftUI

struct AvatarView : View {
    
    @State var image:UIImage?
    let url:String?
    let name:String?
    
    init(user:User){
        self.url = user.avatar
        self.name = user.initials
    }
    
    init(url:String?, name:String?){
        self.url = url
        self.name = name
    }
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    //.frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Text(name ?? "")
                    .scaledToFit()
                    .font(.largeTitle)
                    //.frame(width: 100, height: 100)
                    .background(.gray)
                    .clipShape(Circle())
            }
        }
        .id(url) // ← this forces the view to refresh when url changes
        .task(id: url) { // ← also refetch if url changes
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


