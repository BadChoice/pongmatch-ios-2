import SwiftUI

struct AvatarView : View {
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
            if let url = url, let data = try? Data(contentsOf: URL(string: url)!) {
                Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .scaledToFit()
                    //.frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Text("JP")
                    .scaledToFit()
                    .font(.largeTitle)
                    //.frame(width: 100, height: 100)
                    .background(.gray)
                    .clipShape(Circle())
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


