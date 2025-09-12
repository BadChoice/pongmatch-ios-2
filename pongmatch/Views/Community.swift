import SwiftUI
internal import RevoFoundation

struct Community : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    @State var friends:[User] = []
    
    var body: some View {
        NavigationStack{
            let users = searchText.isEmpty ? friends : searchResults
            List {
                if users.isEmpty {
                    ContentUnavailableView.search
                } else {
                    ForEach(users.sort(by: \.ranking).reversed(), id: \.id) { friend in
                        NavigationLink{
                            UserView(user: friend)
                        } label: {
                            FriendView(user: friend)
                        }
                    }
                }
            }.searchable(text: $searchText)
        }
        
        .task {
            Task {
                friends = ((try? await auth.friends()) ?? [])
            }
        }
        .onChange(of: searchText) { _, newValue in
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                searchResults = ((try? await auth.searchFriends(newValue)) ?? [])
            }
        }
    }
}


#Preview {
    @Previewable @State var selectedFriend = User.unknown()
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return Community()
        .environmentObject(auth)
}
