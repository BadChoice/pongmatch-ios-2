import SwiftUI
internal import RevoFoundation

struct Community : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    @State var friends:[User] = []
    
    var body: some View {
        NavigationStack{
            if searchText.isEmpty {                
                Spacer()
                ContentUnavailableView.search
                Spacer()
            }
            List{
                ForEach(friends.sort(by: \.ranking).reversed(), id: \.id) { friend in
                    UserView(user: friend)
                }
            }
        }
        .searchable(text: $searchText)
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
