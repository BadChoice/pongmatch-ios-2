import SwiftUI

struct DashboardView : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink("Scoreboard") {
                ScoreboardView(score:Score(player1: User.me(), player2: User.unknown()))
            }
            .glassEffect()
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Pongmatch")
        .padding()
        
        .task {
            Task {
                try await auth.fetchMe()
            }
        }
    }
}
