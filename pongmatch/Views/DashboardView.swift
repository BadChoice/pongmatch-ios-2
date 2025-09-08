import SwiftUI

struct DashboardView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @State var isLoadingUser:Bool = true
    
    var body: some View {
        TabView {
            if isLoadingUser {
                ProgressView()
            } else {
                HomeView().tabItem {
                    Image(systemName: "house")      //.renderingMode(.template)
                }
                Community().tabItem {
                    Image(systemName: "person.3")   //.renderingMode(.template)
                }
            }
        }
        .toolbar {
            Button("Logout") { auth.logout() }
            Button("New") { /* TODO */ }
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
    }
}

struct HomeView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    var body: some View {
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
            
            
            VStack(alignment: .leading){
                Text("Next Games").font(.headline)
            
                ScrollView(.horizontal){
                    HStack{
                        CompactGameView(game: Game(
                            id: 1,
                            information: "A nice game",
                            date: Date(),
                            status: .planned,
                            created_at: Date(),
                            updated_at: nil
                        ))
                        CompactGameView(game: Game(
                            id: 1,
                            information: "A nice game",
                            date: Date(),
                            status: .planned,
                            created_at: Date(),
                            updated_at: nil
                        ))
                        CompactGameView(game: Game(
                            id: 1,
                            information: "A nice game",
                            date: Date(),
                            status: .planned,
                            created_at: Date(),
                            updated_at: nil
                        ))
                        CompactGameView(game: Game(
                            id: 1,
                            information: "A nice game",
                            date: Date(),
                            status: .planned,
                            created_at: Date(),
                            updated_at: nil
                        ))
                    }
                }
            }.padding()
            
            Spacer()
            
            NavigationLink("New Game") {
                ScoreboardView(score:Score(player1: auth.user ?? User.unknown(), player2: User.unknown()))
            }
            
            NavigationLink("Scoreboard") {
                ScoreboardView(score:Score(player1: auth.user ?? User.unknown(), player2: User.unknown()))
            }
            
            
            Spacer()
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    return DashboardView().environmentObject(auth)
}
