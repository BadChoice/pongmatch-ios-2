import SwiftUI

struct PodiumView: View {
    let users: [User]
                       
    var body: some View {
        HStack {
            Group {
                if users.count > 1 {
                    userView(user: users[1], position: 1)
                } else {
                    userView(user: User.unknown(), position: 1)
                }
            }.frame(maxWidth: .infinity)
            
            Group {
                if users.count > 0 {
                    userView(user: users[0], position: 0)
                } else {
                    userView(user: User.unknown(), position: 0)
                }
            }.frame(maxWidth: .infinity)
            
            Group {
                if users.count > 2 {
                     userView(user: users[2], position: 2)
                } else {
                    userView(user: User.unknown(), position: 2)
                }
            }.frame(maxWidth: .infinity)
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
        .foregroundStyle(.primary)
    }
            
    
    private func strokeColor(position:Int) -> Color {
        switch position {
        case 0:  .yellow
        case 1:  .gray
        case 2:  .brown
        default: .clear
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
