import SwiftUI
internal import RevoFoundation

struct DashboardView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @State var isLoadingUser:Bool = true
    @State private var scoreboardGame: Game? {
        didSet {
            print("Setting scoreboard game to \(String(describing: scoreboardGame))")
        }
    }
    
    // Identifiable wrapper so we can use .fullScreenCover(item:)
    private struct PresentableGame: Identifiable {
        let id = UUID()
        let game: Game
    }
    @State private var presentableScoreboard: PresentableGame?
        
    var body: some View {
        TabView {
            if isLoadingUser {
                Tab {
                    ProgressView()
                }
            } else {
                Tab("", systemImage: "house") {
                    NavigationStack {
                        HomeView { game in
                            scoreboardGame = game
                            presentableScoreboard = PresentableGame(game: game)
                        }
                    }
                }
                
                Tab("", systemImage: "person.3") {
                    NavigationStack {
                        Community()
                    }
                }
            }
        }
        .tabViewBottomAccessory {
            CurrentGameView().onTapGesture {
                let game = Game.fake()
                scoreboardGame = game
                presentableScoreboard = PresentableGame(game: game)
            }
        }
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
        .fullScreenCover(item: $presentableScoreboard, onDismiss: {
            // If you want to clear the game after dismissal, do it here
            // scoreboardGame = nil
            // Reset orientation to portrait after ScoreboardView is fully dismissed
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              //  OrientationManager.shared.set(.portrait)
            //}
        }) { item in
            ScoreboardView(score: Score(game: item.game))
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
                        AccountView()
                    } label: {
                        Label("Account", systemImage: "person.fill")
                    }
                    Button("Add Friend", systemImage: "person.badge.plus") {
                        
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
