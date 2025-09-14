import SwiftUI
internal import RevoFoundation

struct SearchOpponentView : View {
        
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = [User.unknown()]
    
    @Binding var selectedFriend: User
    var onSelected:(_ player:User) -> Void = {_ in }
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                
                Text("Select Opponent")
                    .font(.title2)
                    .bold()
                    .padding(.bottom)

                
                VStack(spacing: 10) {
                    ForEach(searchResults, id: \.id) { friend in
                        HStack{
                            UserView(user: friend, showUnknownName: true)
                            Spacer()
                        }
                        .onTapGesture() {
                            onSelected(friend)
                        }
                        Divider()
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .searchable(text: $searchText, prompt: "Search for friends")
            .focused($isSearchFocused)
            .onAppear { isSearchFocused = true }
            .onChange(of: searchText) { _, newValue in
                Task {
                    if newValue.isEmpty {
                        searchResults = [User.unknown()]
                    } else {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                        searchResults = ((try? await auth.searchFriends(newValue)) ?? []) + [User.unknown()]
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
    
    return SearchOpponentView(selectedFriend: $selectedFriend)
        .environmentObject(auth)
}
