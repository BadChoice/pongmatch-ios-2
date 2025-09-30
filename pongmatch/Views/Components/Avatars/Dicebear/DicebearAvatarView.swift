import SwiftUI
import CryptoKit

struct DicebearAvatarView: View {
    
    @State private var image: UIImage?
    
    let diceBear:Dicebear
    let url:URL?
    
    init(user: User, style: Dicebear.Style = .adventurer, apiSize: Int = 256) {
        diceBear = Dicebear(user: user, style: style, apiSize: apiSize)
        url = diceBear.url
    }
    
    init(email: String?, style: Dicebear.Style = .adventurer, apiSize: Int = 256) {
        diceBear = Dicebear(email: email, style: style, apiSize: apiSize)
        url = diceBear.url
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
        .id(url?.absoluteString ?? UUID().uuidString)
        .task(id: url) {
            await MainActor.run { image = nil }
            guard let url = url else { return }
            if let downloaded = await Images.download(url) {
                await MainActor.run { image = downloaded }
            }
        }
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

