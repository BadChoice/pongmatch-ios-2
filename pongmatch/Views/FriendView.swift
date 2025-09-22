import SwiftUI

struct FriendView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    let user:User
    
    @State private var selectedSegment = 0
    @State private var deepDetails:UserDeepDetails? = nil
    
    @State var isFollowed:Bool
    @State var fetchGames = ApiAction()
    @State var fetchOneVsOne = ApiAction()
    
    @State var games:[Game] = []
    @State var oneVsOne:Api.OneVsOne? = nil
    
    init(user:User) {
        self.user = user
        self.isFollowed = user.friendship?.isFollowed ?? false
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing:24){
                UserHeaderView(user: user, globalRanking: deepDetails?.global_ranking)
                
                if let deepDetails {
                    HStack{
                        Text("\(deepDetails.followers) followers")
                        Text(" · ")
                        Text("\(deepDetails.following) following")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                if user.id != auth.user.id {
                    
                    HStack(spacing:40) {
                        if user.canBeChallengedByMe() {
                            NavigationLink{
                                CreateGameView(opponent: user)
                            } label: {
                                Label ("Challenge", systemImage: "figure.boxing") .font(.caption)
                            }
                        }
                        FollowButton(user: user, isFollowed: $isFollowed)
                    }
                    
                    Divider()
                    
                }
                
                WinLossBar(
                    me:user,
                    friend:User.unknown(),
                    wins: user.games_won ?? 0,
                    losses: user.games_lost ?? 0
                ).padding()
                
                VStack(alignment: .leading){
                    Text("ELO Evolution")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    EloHistory(user:user)
                        .frame(height: 120)
                        .padding()
                }
                
                Picker("Match Type", selection: $selectedSegment) {
                    Text("Upcoming").tag(0)
                    Text("Recent").tag(1)
                    if auth.user.id != user.id {
                        Text("1 VS 1").tag(2)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Group {
                    switch selectedSegment {
                    case 0:
                        if fetchGames.loading {
                            ProgressView()
                        } else if let error = fetchGames.errorMessage {
                            Text("Error: \(error)")
                                .foregroundStyle(.red)
                                .font(.caption)
                        } else if games.isEmpty {
                            Text("\(user.name) hasn't played any matches yet")
                        } else {
                            GamesScrollview(games: games.filter { !$0.isFinished() })
                        }
                    case 1:
                        if fetchGames.loading {
                            ProgressView()
                        } else if let error = fetchGames.errorMessage {
                            Text("Error: \(error)")
                                .foregroundStyle(.red)
                                .font(.caption)
                        } else if games.isEmpty {
                            Text("\(user.name) hasn't played any matches yet")
                        } else {
                            GamesScrollview(games: games.filter { $0.isFinished() })
                        }
                    case 2:
                        if fetchOneVsOne.loading {
                            ProgressView()
                        } else if let error = fetchOneVsOne.errorMessage {
                            Text("Error: \(error)")
                                .foregroundStyle(.red)
                                .font(.caption)
                        } else if (oneVsOne?.games.isEmpty ?? true){
                            Text("You have no matches against \(user.name)")
                        } else {
                            if let oneVsOne {
                                WinLossBar(
                                    me:auth.user,
                                    friend:user,
                                    wins: oneVsOne.won,
                                    losses: oneVsOne.lost
                                ).padding(.horizontal, 4)
                            }
                            GamesScrollview(games: oneVsOne?.games ?? [])
                        }
                    default:
                        EmptyView()
                    }
                }
                .padding()
                
                Spacer()
            }
        }.task {
            fetchDetails()
            fetchFriendGames()
            apiFetchOneVsOne()
        }
    }
    
    private func fetchDetails(){
        Task {
            let deepDetails = try? await auth.api.deepDetails(user)
            withAnimation {
                self.deepDetails = deepDetails
            }
        }
    }
    
    private func fetchFriendGames(){
        Task {
            await fetchGames.run {
                games = try await auth.api.friendGames(user.id)
            }
        }
    }
    
    private func apiFetchOneVsOne(){
        if auth.user.id == user.id { return }
        Task {
            await fetchOneVsOne.run {
                oneVsOne = try await auth.api.friendOneVsOne(user.id)
            }
        }
    }
}


struct FollowButton : View {
    @EnvironmentObject private var auth: AuthViewModel
    let user:User
    @Binding var isFollowed:Bool
    
    var body: some View {
        
        Button {
            Task {
                try await isFollowed ? auth.api.unfollow(user) : auth.api.follow(user)
                withAnimation { isFollowed.toggle()}
            }
        } label: {
            Label(isFollowed ? "Following" : "Follow",
                  systemImage: "heart.fill")
                
        }
        .font(.caption)
        .padding(6)
        .background(isFollowed ? Color.accentColor : .clear)
        .foregroundStyle(isFollowed ? .white : .blue)
        .cornerRadius(8)
    }

}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return FriendView(user: User.me())
        .environmentObject(auth)
}
