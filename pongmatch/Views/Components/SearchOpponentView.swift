import SwiftUI
internal import RevoFoundation

struct SearchOpponentView : View {
        
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    @State var recentOpponents: [User] = []
    
    @Binding var selectedFriend: User
    var onSelected:(_ player:User) -> Void = {_ in }
    @FocusState private var isSearchFocused: Bool
        
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(searchResults, id: \.id) { friend in
                        HStack{
                            UserView(user: friend)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture() {
                            onSelected(friend)
                        }
                    }
                }
                if searchText.isEmpty {
                    Section(header: Text("Recent")) {
                        ForEach(recentOpponents, id: \.id) { friend in
                            HStack{
                                UserView(user: friend)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture() {
                                onSelected(friend)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Opponent")
            .searchable(text: $searchText, prompt: "Search for friends")
            .focused($isSearchFocused)
            .onAppear { isSearchFocused = true }
            .onChange(of: searchText) { _, newValue in
                search(newValue)
            }
        }
        .task {
            recentOpponents = auth.games.filter {
                $0.isFinished()
            }.map {
                $0.player1.id == auth.user?.id ? $0.player2 : $0.player1
            }.unique(\.id).filter{
                $0.canBeChallengedByMe()
            } + [User.unknown()]
        }
    }
    
    private func search(_ text:String){
        Task {
            if text.isEmpty {
                searchResults = [User.unknown()]
            } else {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                searchResults = ((try? await auth.searchFriends(text)) ?? []).filter {
                    $0.canBeChallengedByMe()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedFriend = User.unknown()
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return SearchOpponentView(selectedFriend: $selectedFriend)
        .environmentObject(auth)
}
