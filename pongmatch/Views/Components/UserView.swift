import SwiftUI

struct UserView : View {
    let user:User
    let winner:Bool
    
    init(user: User, winner: Bool = false) {
        self.user = user
        self.winner = winner
    }
    
    var body: some View {
        HStack{
            AvatarView(user:user, winner:winner).frame(width: 48)
            
            if user.id != User.unknown().id {
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
}

struct CompactUserView : View {
    let user:User
    let winner:Bool
    
    init(user: User, winner: Bool = false) {
        self.user = user
        self.winner = winner
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .center, spacing:4){
                AvatarView(user:user, winner: winner).frame(width: 40)
                
                if user.id != User.unknown().id {
                    Text(user.name)
                        .font(.footnote)
                    //    .lineLimit(2, reservesSpace: true)
                    
                    Text("\(user.ranking)").font(.system(size:10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(.black)
                        .clipShape(.capsule)
                }
            }
        }
    }
}

#Preview {
    UserView(user: User.me(), winner: true)
}

#Preview {
    CompactUserView(user: User.me())
}
