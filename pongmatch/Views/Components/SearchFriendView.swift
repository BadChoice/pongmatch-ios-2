import SwiftUI
internal import RevoFoundation

struct SearchFriendView : View {
    
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = [User.unknown()]
    
    @Binding var selectedFriend: User
    var onSelected:(_ player:User) -> Void = {_ in }
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchText.isEmpty {
                    Spacer()
                    Text("Search your friends")
                    Spacer()
                } else {
                    List {
                        ForEach(searchResults, id: \.id) { friend in
                            UserView(user: friend)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Community") // Add a title to ensure navigation bar visibility
            .searchable(text: $searchText, prompt: "Search for friends")
            .onChange(of: searchText) { _, newValue in
                Task {
                    if newValue.isEmpty {
                        searchResults = []
                    } else {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                        searchResults = (try? await auth.searchFriends(newValue)) ?? []
                    }
                }            
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
