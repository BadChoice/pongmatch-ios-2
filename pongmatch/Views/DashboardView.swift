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
                        NavigationStack{
                            Text("Searching...")
                        }.searchable(text:$search)
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
                UserHeaderView(user: auth.user ?? User.unknown())
                
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
                        if let user = auth.user {w
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
                        FeedbackView()
                    } label: {
                        Label("How it works", systemImage: "questionmark.circle")
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
    @Binding var refreshID: UUID

    var games: [Game]  {
        auth.games
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let watchGames:[Game] = Storage().get(.gamesFinishedOnWatch) {
                VStack(alignment: .leading){
                    Text("Watch finished games").font(.headline)
                    GamesScrollview(games:watchGames)
                }.padding()
            }
            
            let currentGames = games.filter { $0.status == .ongoing }
            VStack(alignment: .leading){
                Text("Current Games").font(.headline)
                GamesScrollview(games:currentGames)
            }.padding()
            
            let challenges = games.filter { $0.status == .waitingOpponent }
            if challenges.count > 0 {
                VStack(alignment: .leading){
                    Text("You have been challenged!").font(.headline)
                    GamesScrollview(games:challenges)
                }.padding()
            }
            
            let upcoming = games.filter { $0.status == .planned }
            if upcoming.count > 0 {
                VStack(alignment: .leading){
                    Text("Next Games").font(.headline)
                    GamesScrollview(games:upcoming)
                }.padding()
            }
            
            VStack(alignment: .leading){
                Text("Finished Games").font(.headline)
                GamesScrollview(games:games.filter { $0.isFinished()
                })
            }.padding()
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
