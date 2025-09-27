import SwiftUI
internal import RevoFoundation

struct DashboardView : View {
    
    enum TabSelection : Int {
        case home       = 1
        case community  = 2
        case search     = 3
    }
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @State var isLoadingUser:Bool = true
    @State var search: String = ""
    @State var activeTab: TabSelection = .home
    
    @State private var scoreboardGame: Game? {
        didSet {
            print("Setting scoreboard game to \(String(describing: scoreboardGame))")
        }
    }
    
    // Identifiable wrapper so we can use .fullScreenCover(item:)
    private struct PresentableGame: Identifiable {
        let id = UUID()
        let score: Score
    }
    @State private var presentableScoreboard: PresentableGame?
    
    // Keep explicit navigation paths so we know when a tab is at root
    @State private var homePath = NavigationPath()
    @State private var communityPath = NavigationPath()
    
    // If any tab’s stack is not at root, hide the tab bar (and bottom accessory)
    private var shouldHideTabBar: Bool {
        !homePath.isEmpty || !communityPath.isEmpty
    }
        
    var body: some View {
        TabView(selection:$activeTab) {
            if isLoadingUser {
                Tab("", systemImage: "hourglass", value:.home) {
                    ProgressView()
                }
            } else{
                Tab("Home", systemImage: "house", value:.home) {
                    NavigationStack(path: $homePath) {
                        HomeView { game in
                            scoreboardGame = game
                            presentableScoreboard = PresentableGame(score:Score(game: game))
                        }
                    }
                }
                
                Tab("Community", systemImage: "person.3", value:.community) {
                    NavigationStack(path: $communityPath) {
                        Community()
                    }
                }
                
                if [.community, .search].contains(activeTab) {
                    Tab("Search", systemImage: "magnifyingglass", value:.search, role: .search) {
                        SearchFriendsView()
                    }
                }
            }
        }
        // Only show the bottom accessory when we are at the root of the current tab
        .tabViewBottomAccessory {
            Group {
                if !shouldHideTabBar {
                    CurrentGameView().onTapGesture {
                        presentableScoreboard = PresentableGame(score:SyncedScore.shared.score)
                    }
                }
            }
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
        .tabBarMinimizeBehavior(.onScrollDown)
        .task {
            Task {
                defer {
                    isLoadingUser = false
                }
                guard auth.user == nil else { return }
                try await auth.fetchMe()
            }
        }
        .fullScreenCover(item: $presentableScoreboard) { item in
            ScoreboardView(score: item.score)
        }
    }
}

struct HomeView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @ObservedObject private var syncedScore = SyncedScore.shared
    
    @State private var showScoreboardSelectionModal = false
    @State private var refreshId = UUID()
    
    var onStartScoreboard: (Game) -> Void
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                NavigationLink {
                    FriendView(user: auth.user)
                } label: {
                    UserHeaderView(user: auth.user ?? User.unknown(), showDetails: false)
                }
                
                Divider()
                
                HStack {
                    Button("Scoreboard", systemImage: "square.split.2x1"){
                        showScoreboardSelectionModal = true
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .bold()
                    .glassEffect(.regular.tint(Color.accentColor).interactive())
                    
                }.padding()
                
                Divider()
                
                GamesHomeView(refreshID: $refreshId)
                
                Spacer()
            }
        }
        .refreshable {
            refreshId = UUID()
        }
        .toolbar {
            //https://xavier7t.com/liquid-glass-navigation-bar-in-swiftui?source=more_articles_bottom_blogs
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CreateGameView()
                } label: {
                    Label("Create Game", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    NavigationLink {
                        if let user = auth.user {
                            FriendView(user: user)
                        }
                    } label: {
                        Label("Profile", systemImage: "figure.table.tennis")
                    }
                    
                    NavigationLink {
                        AccountView()
                    } label: {
                        Label("Account", systemImage: "person.fill")
                    }
                                        
                    
                    Divider()
                    
                    NavigationLink {
                        HowItWorksView()
                    } label: {
                        Label("How it works", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink {
                        BuyMeACoffeeView()
                    } label: {
                        Label("Buy me a Coffee", systemImage: "cup.and.saucer.fill")
                    }
                    
                    ShareLink(item: URL(string: Pongmatch.appStoreUrl)!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        Label("Feedback", systemImage: "bubble")
                    }
                    
                    Divider()
                    Button("Logout", systemImage: "arrow.right.square") {
                        auth.logout()
                    }
                }
                label : {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showScoreboardSelectionModal) {
            ScoreboardSelectionView { game in
                showScoreboardSelectionModal = false
                onStartScoreboard(game)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            Apn.refreshPushToken()
        }
    }
}


struct GamesHomeView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @ObservedObject private var watchGames = WatchFinishedGames.shared
    @Binding var refreshID: UUID

    var games: [Game]  {
        auth.games
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !watchGames.games.isEmpty {
                VStack(alignment: .leading){
                    Label("Finished games on  watch", systemImage: "applewatch").font(.headline)
                    GamesScrollView(games:watchGames.games)
                }.padding()
            }
            
            let currentGames = games.filter { $0.status == .ongoing }
            if !currentGames.isEmpty {
                VStack(alignment: .leading){
                    Label("Current Games", systemImage: GameStatus.ongoing.icon).font(.headline)
                    GamesScrollView(games:currentGames)
                }.padding()
            }
            
            let challenges = games.filter { $0.status == .waitingOpponent }
            if !challenges.isEmpty {
                VStack(alignment: .leading){
                    Label("Pending acceptance", systemImage:"clock").font(.headline)
                    GamesScrollView(games:challenges)
                }.padding()
            }
            
            let upcoming = games.filter { $0.status == .planned }
            if !upcoming.isEmpty {
                VStack(alignment: .leading){
                    Label("Upcoming", systemImage: GameStatus.planned.icon).font(.headline)
                    GamesScrollView(games:upcoming)
                }.padding()
            }
            
            let finished = games.filter { $0.isFinished() }
            if !finished.isEmpty {
                VStack(alignment: .leading){
                    Label("Finished Games", systemImage: GameStatus.finished.icon).font(.headline)
                    GamesScrollView(games: finished)
                }.padding()
            }
        }
        .task {
            Task {
                try? await auth.loadGames()
            }
        }
        .onChange(of: refreshID) {
            Task { try? await auth.loadGames() }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return NavigationStack {
        DashboardView()
    }.environmentObject(auth)
}
