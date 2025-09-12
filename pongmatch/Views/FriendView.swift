import SwiftUI

struct FriendView : View {
    let user:User
    
    var body: some View {
        VStack{
            UserHeaderView(user: user)            
            Divider()
        }
    }
}

#Preview {
    FriendView(user: User.me())
}
