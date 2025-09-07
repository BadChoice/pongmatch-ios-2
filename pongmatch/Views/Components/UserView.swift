import SwiftUI

struct UserView : View {
    let user:User
    
    var body: some View {
        HStack{
            AvatarView(user:user).frame(width: 48)
            
            VStack(alignment: .leading, spacing:4){
                Text(user.name).font(.headline)
                Text("\(user.ranking)").font(.system(size:12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.black)
                    .clipShape(.capsule)
            }
        }
    }
}

#Preview {
    UserView(user: User.me())
}
