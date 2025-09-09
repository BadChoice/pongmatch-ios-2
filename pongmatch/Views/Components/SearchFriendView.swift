import SwiftUI
internal import RevoFoundation

struct SearchFriendView : View {
    
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = [User.unknown()] // Assuming Friend is your opponent model
    
    @Binding var selectedFriend: User
    var onSelected:(_ player:User) -> Void = {_ in }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    ForEach(searchResults, id: \.id) { friend in
                        Button {
                            selectedFriend = friend
                            onSelected(friend)
                        } label: {
                            HStack {
                                UserView(user: friend)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .task {
            searchResults = [selectedFriend, User.unknown()].unique(\.id)
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            Task {
                searchResults = ((try? await auth.searchFriends(newValue)) ?? []) +  [User.unknown()]
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedFriend = User.unknown()
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return SearchFriendView(selectedFriend: $selectedFriend)
        .environmentObject(auth)
}
