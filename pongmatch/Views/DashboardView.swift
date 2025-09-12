import SwiftUI
internal import RevoFoundation

struct DashboardView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @State var isLoadingUser:Bool = true
    @State private var selectedScore: Score?

        
    var body: some View {
        TabView {
            if isLoadingUser {
                ProgressView()
            } else {
                HomeView { score in
                    selectedScore = score
                    nav.push("scoreboard")
                }.tabItem {
                    Image(systemName: "house")
                }
                Community().tabItem {
                    Image(systemName: "person.3")
                }
            }
        }
        .toolbar {
            Menu {
                Button("Account", systemImage: "person.fill") {
                    
                }
                Button("Add Friend", systemImage: "person.badge.plus") {
                    
                }
                Button("Feedback", systemImage: "bubble") {
                    
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
        .task {
            Task {
                defer {
                    isLoadingUser = false
                }
                guard auth.user == nil else { return }
                try await auth.fetchMe()
                
            }
        }
        .navigationDestination(for: String.self) { target in
            if target == "scoreboard"{
                ScoreboardView(
                    score: selectedScore ??  Score(
                        player1: auth.user ?? User.unknown(),
                        player2: User.unknown(),
                    )
                )
            }
        }
    }
}

struct HomeView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @ObservedObject private var syncedScore = SyncedScore.shared
    @State private var showScoreboardSelectionModal = false
    @State private var refreshId = UUID()
    
    var onStartScoreboard: (Score) -> Void
    
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
                    .glassEffect(.regular.tint(.black).interactive())
                    
                    if syncedScore.score != nil {
                        Spacer().frame(width:20)
                        NavigationLink("Continue scoreboard") {
                            ScoreboardView()
                        }
                    }
                }.padding()
                
                Divider()
                
                GamesHomeView(refreshID: $refreshId)

                Spacer()
            }
        }
        .refreshable {
            refreshId = UUID()
        }
        .sheet(isPresented: $showScoreboardSelectionModal) {
            ScoreboardSelectionView { player2, winningCondition, rankingType in
                showScoreboardSelectionModal = false
                onStartScoreboard(Score(
                    player1: auth.user!,
                    player2: player2,
                    winningCondition: winningCondition,
                    rankingType: rankingType
                    )
                )
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }     
    }
}

struct GamesHomeView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @Binding var refreshID: UUID

    @State var games: [Game] = []
    @State var isLoadingGames = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading){
                Text("Current Games").font(.headline)
                GamesScrollview(games:games.filter { $0.status == .ongoing
                })
            }.padding()
            
            VStack(alignment: .leading){
                Text("Finished Games").font(.headline)
                GamesScrollview(games:games.filter { $0.isFinished()
                })
            }.padding()
            
            VStack(alignment: .leading){
                Text("Next Games").font(.headline)
                GamesScrollview(games:games.filter { $0.isUpcoming()
                })
            }.padding()
        }
        .task {
            await loadGames()
        }
        .onChange(of: refreshID) {
            Task { await loadGames() }
        }
    }
    
    private func loadGames() async {
        isLoadingGames = true
        Task {
            games = ((try? await auth.api.games()) ?? [])
                .sort(by: \.date)
                .reversed()
            isLoadingGames = false
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return DashboardView().environmentObject(auth)
}

