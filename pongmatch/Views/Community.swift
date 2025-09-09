import SwiftUI

struct Community : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    var body: some View {
        NavigationStack{
            if searchText.isEmpty {
                Spacer()
                Text("Search your friends")
                Spacer()
            }
            List{
                ForEach(searchResults, id: \.id) { friend in
                    UserView(user: friend)
                    Spacer()
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                searchResults = ((try? await auth.searchFriends(newValue)) ?? []) +  []
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
