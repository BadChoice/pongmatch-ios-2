import SwiftUI
internal import RevoFoundation

struct Community : View {
    
    @EnvironmentObject private var auth: AuthViewModel
        
    @State var friends:[User] = []
    @State var loading:Bool = false
    
    @State var searchingUsers:Bool = false
    
    var topUsers: [User] {
        var users = friends
        
        if let user = auth.user {
            users.append(user)
        }
        
        return users
            .sort(by: \.ranking)
            .reversed()
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        let users = friends
        List {
            if loading {
                ProgressView()
            } else {
                if !users.isEmpty {
                    Section {
                        PodiumView(users: topUsers)
                            .padding(.vertical)
                            .padding(.top, 20)
                    }
                }
                
                Section {
                    if users.isEmpty {
                        ContentUnavailableView {
                            Label("No friends", systemImage: "person.3")
                        } description: {
                            Text("Add some friends to start playing!")
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
                    }
                }
            }
        }
        .sheet(isPresented: $searchingUsers){
            SearchUsersView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)                
        }
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
            
            ToolbarItem(placement: .topBarTrailing ){
                ShareLink(item: URL(string: Pongmatch.appStoreUrl)!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
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
                .tabItem { Image(systemName: "person.3") }
        }
    }.environmentObject(auth)
}
