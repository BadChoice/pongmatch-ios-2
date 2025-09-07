import SwiftUI

struct DashboardView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @State var isLoadingUser:Bool = true
    
    var body: some View {
        Group {
            if isLoadingUser {
                ProgressView()
            } else {
                VStack(spacing: 20) {
                    UserView(user: auth.user ?? User.unknown())
                    VStack(spacing:8) {
                        if let lastPlayed = auth.user.last_match_date {
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
                    Spacer()
                    
                    NavigationLink("Scoreboard") {
                        ScoreboardView(score:Score(player1: auth.user ?? User.unknown(), player2: User.unknown()))
                    }
                    .padding()
                    .glassEffect()
                }
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
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    return DashboardView().environmentObject(auth)
}
