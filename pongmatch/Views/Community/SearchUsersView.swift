import SwiftUI

struct SearchUsersView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var users: [User]?
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    
    @FocusState private var isSearchFocused: Bool
    
    init(_ users:[User]? = nil) {
        self.users = users
        //print(users)
        //print(self.users)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if isSearching && (users?.isEmpty ?? true) && !searchText.isEmpty {
                    ProgressView("Searching…")
                        .padding()
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                if (users?.isEmpty ?? true) {
                    ContentUnavailableView {
                        Label("No players", systemImage: "person.3.fill")
                    } description: {
                        Text("Search for other players and follow them to start a game!")
                            .padding(.top)
                    }
                }
                        
                if let users {
                    ForEach(users, id: \.id) { user in
                        NavigationLink {
                            FriendView(user: user)
                        } label: {
                            HStack {
                                UserView(user: user, showUsername: true)
                                Spacer()
                                friendshipView(for: user)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Players")
        }
        .listRowSeparator(.visible, edges: .all)
        .foregroundStyle(.primary)
        .focused($isSearchFocused)
        .onAppear { isSearchFocused = true }
        .navigationTitle("Search Users")
        .searchable(text: $searchText, prompt: "Search players")
        .onChange(of: searchText) { _, newValue in
            debounceSearch(with: newValue)
        }        
    }
}

private extension SearchUsersView {
    func debounceSearch(with text: String) {
        // Simple debounce using Task cancellation
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
            await performSearch(text: text)
        }
    }
    
    @MainActor
    func performSearch(text: String) async {
        guard let api = auth.api else { return }
        // Empty text clears results
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            users = []
            errorMessage = nil
            isSearching = false
            return
        }
        
        isSearching = true
        errorMessage = nil
        do {
            users = try await api.users.search(text)
        } catch {
            errorMessage = "\(error)"
        }
        isSearching = false
    }
    
    @ViewBuilder
    func friendshipView(for user: User) -> some View {
        let friendship = user.friendship
        if let friendship {
            HStack {
                Image(systemName: "heart.fill")
                Text(friendship.isFollowed ? "Following" : "Follow")
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(friendship.isFollowed ? Color.gray.opacity(0.15) : Color.accentColor)
            .foregroundStyle(friendship.isFollowed ? .primary : Color.white)
            .cornerRadius(8)
        }
    }
}

// A cancellable search Task stored at file scope for simple debouncing per view instance.
private var searchTask: Task<Void, Never>?

#Preview {
    @Previewable @State var showingSheet = true
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    
    return SearchUsersView([User.me(), User.me(), User.me(), User.me()])
            .environmentObject(auth)
}
