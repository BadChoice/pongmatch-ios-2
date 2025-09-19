import SwiftUI

@MainActor
struct CurrentGameView : View {
    
    @ObservedObject private var syncedScore = SyncedScore.shared
        
    var body: some View {
        Group {
            if let score = syncedScore.score {
                NavigationLink {
                    ScoreboardView(score: score)
                } label:{
                    HStack {
                        PulseView()
                        
                        Spacer()
                        
                        AvatarView(user: score.game.player1)
                            .frame(width: 24, height:24)
                        Group {
                            let result = score.setsResult
                            Text("\(result.player1) - \(result.player2)")
                        }.font(.headline)
                        
                        AvatarView(user: score.game.player2)
                            .frame(width: 24, height:24)
                        
                        Spacer()
                        
                        Image(systemName: "play.fill")
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                HStack {
                    Image(systemName: "square.split.2x1")
                    Text("Start a scoreboard")
                    Spacer()
                    Image(systemName: "play.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity)
    }
}
