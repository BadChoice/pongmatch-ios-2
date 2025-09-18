import SwiftUI

struct SearchUsersView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var searchText: String = ""
    @State private var users: [User] = []
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    
    // Per-user loading states for follow/unfollow and friendship fetch
    @State private var loadingFriendship: Set<Int> = []
    @State private var mutatingFollow: Set<Int> = []
    
    init(_ users: [User]? = nil) {
        self.users = users ?? []
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Search Players")
                    .font(.title2)
                    .bold()
                    .padding(.bottom)
                
                if isSearching && users.isEmpty && !searchText.isEmpty {
                    ProgressView("Searching…")
                        .padding()
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                List(users, id: \.id) { user in
                    NavigationLink {
                        FriendView(user: user)
                    } label: {
                        HStack {
                            UserView(user: user)
                            Spacer()
                            friendshipView(for: user)
                        }
                        .task {
                            await ensureFriendship(for: user)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search Users")
        .searchable(text: $searchText, prompt: "Search users")
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
            var found = try await api.users(search: text)
            let friendshipById = Dictionary(uniqueKeysWithValues: users.compactMap { ($0.id, $0.friendship) })
            for i in found.indices {
                if found[i].friendship == nil, let known = friendshipById[found[i].id] {
                    found[i].friendship = known
                }
            }
            users = found
        } catch {
            errorMessage = "\(error)"
        }
        isSearching = false
    }
    
    @ViewBuilder
    func friendshipView(for user: User) -> some View {
        let isLoadingFriendship = loadingFriendship.contains(user.id)
        let isMutating = mutatingFollow.contains(user.id)
        let friendship = user.friendship
        
        HStack(spacing: 8) {
            // Status label
            Group {
                if isLoadingFriendship {
                    ProgressView().frame(width: 20, height: 20)
                }
            }
            
            // Follow/Unfollow button
            if let friendship {
                Button {

                } label: {
                    HStack {
                        if isMutating {
                            ProgressView().tint(.white)
                        }
                        Label(
                            friendship.isFollowed ? "Following" : "Follow", systemImage: "heart.fill"
                        ).font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(friendship.isFollowed ? .black : Color.gray.opacity(0.15))
                    .foregroundStyle(friendship.isFollowed ? .white : .black)
                    .cornerRadius(8)
                }
                .disabled(isMutating)
                .animation(.default, value: friendship.isFollowed)
            }
        }
    }
    
    func ensureFriendship(for user: User) async {
        guard let api = auth.api else { return }
        guard users.first(where: { $0.id == user.id })?.friendship == nil else { return }
        guard loadingFriendship.insert(user.id).inserted else { return }
        defer { loadingFriendship.remove(user.id) }
        
        do {
            let status = try await api.friendShipStatus(user)
            updateUser(user.id) { $0.friendship = status }
        } catch {
            // Soft-fail: leave friendship nil
        }
    }
    

    func updateUser(_ id: Int, mutate: (inout User) -> Void) {
        if let idx = users.firstIndex(where: { $0.id == id }) {
            var copy = users[idx]
            mutate(&copy)
            users[idx] = copy
        }
    }
}

// A cancellable search Task stored at file scope for simple debouncing per view instance.
private var searchTask: Task<Void, Never>?

#Preview {
    @Previewable @State var showingSheet = true
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    
    return NavigationStack {
        VStack{}.sheet(isPresented:$showingSheet) {
            SearchUsersView([User.me()])
                
        }
    }.environmentObject(auth)
}
