import SwiftUI

struct DashboardView : View {
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
    }
}
