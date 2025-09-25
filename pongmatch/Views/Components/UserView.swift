import SwiftUI

struct UserView : View {
    let user:User
    let winner:Bool
    let showUsername:Bool
    
    init(user: User, winner: Bool = false, showUsername:Bool = false) {
        self.user = user
        self.winner = winner
        self.showUsername = showUsername
    }
    
    var body: some View {
        HStack{
            AvatarView(user:user, winner:winner)
                .frame(width: 48)
            
            VStack(alignment: .leading, spacing:4) {
                Text(user.name)
                    .lineLimit(1, reservesSpace: true)
                    .font(.headline)
                
                HStack {
                    if user.id != User.unknown().id {
                        Text("\(user.ranking)")
                            .font(.system(size:12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.accentColor)
                            .clipShape(.capsule)
                    }
                    else {
                        Text("")
                    }
                    
                    if showUsername {
                        Text("@" + user.username)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        
        }
    }
}

struct CompactUserView : View {
    let user:User
    let winner:Bool
    let showUsername:Bool
    
    init(user: User, winner: Bool = false, showUsername:Bool = false) {
        self.user = user
        self.winner = winner
        self.showUsername = showUsername
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .center, spacing:4){
                AvatarView(user:user, winner: winner).frame(width: 40)
                                
                Text(user.name)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                //    .lineLimit(2, reservesSpace: true)
                
                if showUsername {
                    Text("@" + user.username)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                if user.id != User.unknown().id {
                    Text("\(user.ranking)").font(.system(size:10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.accentColor)
                        .clipShape(.capsule)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing:20) {
        UserView(user: User.me(), winner: false)
        UserView(user: User.me(), winner: true)
        UserView(user: User.me(), winner: true, showUsername: true)
        UserView(user: User.unknown(), winner: false)
        UserView(user: User.unknown(), winner: false, showUsername: true)
        Divider()
        CompactUserView(user: User.me())
        CompactUserView(user: User.me(), winner:true)
        CompactUserView(user: User.me(), winner:true, showUsername: true)
        CompactUserView(user: User.unknown(), winner:true, showUsername: true)
    }
}
