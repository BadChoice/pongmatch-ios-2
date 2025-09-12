import SwiftUI
internal import RevoFoundation

struct Community : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    @State var friends:[User] = []
    
    var body: some View {
        let users = searchText.isEmpty ? friends : searchResults
        List {
            if users.isEmpty {
                ContentUnavailableView {
                    Label(searchText.isEmpty ? "No friends" : "No results", systemImage: searchText.isEmpty ? "person.3" : "magnifyingglass")
                } description: {
                    Text(searchText.isEmpty ? "Add some friends to start playing!" : "Try searching for another name.")
                } actions:{
                    Button("Add Friend") {
                        //nav.push("addFriend")
                    }
                }
            } else {
                ForEach(users.sort(by: \.ranking).reversed(), id: \.id) { friend in
                    NavigationLink{
                        FriendView(user: friend)
                    } label: {
                        UserView(user: friend)
                    }
                }
            }
        }.overlay(
            CustomSearchBar(text: $searchText),
            alignment: .bottom
        )
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
    
    return NavigationStack {
        TabView
        {
            Community()
                .tabItem { Image(systemName: "person.3")}
        }
    }.environmentObject(auth)
}
