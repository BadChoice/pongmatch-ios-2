import SwiftUI
internal import RevoFoundation

struct Community : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    @State var friends:[User] = []
    @State var loading:Bool = false
    
    @State var searchingUsers:Bool = false
    
    var body: some View {
        let users = searchText.isEmpty ? friends : searchResults
        List {
            if loading {
                ProgressView()
            } else {
                if users.isEmpty {
                    ContentUnavailableView {
                        Label(searchText.isEmpty ? "No friends" : "No results", systemImage: searchText.isEmpty ? "person.3" : "magnifyingglass")
                    } description: {
                        Text(searchText.isEmpty ? "Add some friends to start playing!" : "Try searching for another name.")
                    } actions:{
                        Button("Add Friend") {
                            searchingUsers = true
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
                    Spacer().frame(height: 80)
                }
            }
        }
        .sheet(isPresented: $searchingUsers){
            SearchUsersView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)                
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search for friends")
        .task {
            Task {
                friends = ((try? await auth.friends()) ?? [])
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "plus") {
                    searchingUsers = true
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            loading = true
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s delay
                searchResults = ((try? await auth.searchFriends(newValue)) ?? [])
                loading = false
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
