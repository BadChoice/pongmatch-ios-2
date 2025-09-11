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
                    Image(systemName: "house")      //.renderingMode(.template)
                }
                Community().tabItem {
                    Image(systemName: "person.3")   //.renderingMode(.template)
                }
            }
        }
        
        .toolbar {
            Button{ }
            label : {
                Image(systemName: "ellipsis")
            }
            //Button("Logout") { auth.logout() }
            //Button("New") { /* TODO */ }
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
    
    var onStartScoreboard: (Score) -> Void
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                UserView(user: auth.user ?? User.unknown())
                VStack(spacing:8) {
                    if let lastPlayed = auth.user?.last_match_date {
                        Text("Last played \(lastPlayed.displayForHumans)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack{
                        Text("WON").frame(width:80)
                        Text("ELO").frame(width:80)
                        Text("LOST").frame(width:80)
                    }.foregroundStyle(.gray)
                    HStack{
                        Text("\(auth.user?.games_won ?? 0)").frame(width:80)
                        Text("\(auth.user?.ranking ?? 0)").frame(width:80)
                        Text("\(auth.user?.games_lost ?? 0)").frame(width:80)
                    }.bold()
                }

                Divider()
                Spacer()
                
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
                }.padding(.horizontal)
                
                GamesHomeView()

                Spacer()
            }
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
            .presentationDetents([.medium, .large]) // Bottom sheet style
            .presentationDragIndicator(.visible)    // Show the small slider on top
        }
    }
}

struct GamesHomeView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
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
            isLoadingGames = true
            Task {
                games = ((try? await auth.api.games()) ?? [])
                    .sort(by: \.date)
                    .reversed()
                isLoadingGames = false
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return DashboardView().environmentObject(auth)
}

