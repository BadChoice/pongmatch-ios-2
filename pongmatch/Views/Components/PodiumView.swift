import SwiftUI

struct PodiumView: View {
    let users: [User]
                       
    var body: some View {
        HStack {
            Group{
                if users.count > 1 {
                    NavigationLink {
                        FriendView(user: users[1])
                    } label: {
                        userView(user: users[1], position: 1)
                    }.navigationLinkIndicatorVisibility(.hidden)
                } else {
                    userView(user: User.unknown(), position: 1)
                }
            }.frame(minWidth: 0, maxWidth: .infinity)
            
            Group {
                if users.count > 0 {
                    NavigationLink {
                        FriendView(user: users[0])
                    } label: {
                        userView(user: users[0], position: 0)
                    }.navigationLinkIndicatorVisibility(.hidden)
                } else {
                    userView(user: User.unknown(), position: 0)
                }
            }.frame(minWidth: 0, maxWidth: .infinity)
            
            Group {
                if users.count > 2 {
                    NavigationLink {
                        FriendView(user: users[2])
                    } label: {
                        userView(user: users[2], position: 2)
                    }.navigationLinkIndicatorVisibility(.hidden)
                } else {
                    userView(user: User.unknown(), position: 2)
                }
            }.frame(minWidth: 0, maxWidth: .infinity)                
        }
    }
    
    private func userView(user: User, position: Int) -> some View {
        VStack {
            AvatarView(user: user)
                .frame(width: position == 0 ? 80 : 60, height: position == 0 ? 80 : 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(strokeColor(position: position), lineWidth: 4)
                )
                .overlay {
                    if position == 0 {
                        Image(systemName: "crown.fill")
                            .resizable()
                            .padding(4)
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.black)
                            .background(.yellow, in: Circle())
                            .offset(x: 0, y: -48)
                    }
                }
            
            Text(user.name)
                .font(position == 0 ? .default : .footnote)
                .fontWeight(position == 0 ? .bold : .regular)
                .multilineTextAlignment(.center)
            
            Text("\(user.ranking)")
                .font(position == 0 ? .caption : .caption2)
                .fontWeight(position == 0 ? .bold : .regular)
                .foregroundStyle(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.accentColor)
                .clipShape(.capsule)
        }
    }
            
    
    private func strokeColor(position:Int) -> Color {
        switch position {
        case 0: Color.yellow
        case 1:  Color.gray
        case 2:  Color.brown
        default: Color.clear
        }
    }

}


#Preview {
    PodiumView(users:[
        User.me(),
        User.me(),
        User.me(),
    ])
    .padding(30)
}
