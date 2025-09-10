import SwiftUI

struct UserView : View {
    let user:User
    
    var body: some View {
        HStack{
            AvatarView(user:user).frame(width: 48)
            
            VStack(alignment: .leading, spacing:4){
                Text(user.name)
                    .lineLimit(1, reservesSpace: true)
                    .font(.headline)
                
                Text("\(user.ranking)")
                    .font(.system(size:12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.black)
                    .clipShape(.capsule)
            }
        }
    }
}

struct CompactUserView : View {
    let user:User
    
    var body: some View {
        HStack{
            VStack(alignment: .center, spacing:4){
                AvatarView(user:user).frame(width: 40)
                
                Text("\(user.ranking)").font(.system(size:10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.black)
                    .clipShape(.capsule)
                
                Text(user.name)
                    .font(.caption2)
                    .lineLimit(2, reservesSpace: true)
            }
        }
    }
}

#Preview {
    UserView(user: User.me())
}

#Preview {
    CompactUserView(user: User.me())
}
