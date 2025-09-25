import SwiftUI

@MainActor
struct CurrentGameView : View {
    
    @ObservedObject private var syncedScore = SyncedScore.shared
        
    var body: some View {
        if let score = syncedScore.score {
            HStack {
                PulseView()
                
                Spacer().frame(width:20)
                
                AvatarView(user: score.game.player1)
                    .frame(width: 24, height:24)
                Group {
                    let result = score.setsResult
                    Text("\(result.player1) - \(result.player2)")
                }.font(.headline)
                
                AvatarView(user: score.game.player2)
                    .frame(width: 24, height:24)
                
                Spacer().frame(width:20)
                
                HStack {
                    let setsSnapshot = score.sets   //To avoid crash when reiterating
                    ForEach(Array(setsSnapshot.enumerated()), id: \.offset) { _, set in
                        VStack {
                            Text("\(set.forPlayer(.player1))").bold(set.forPlayer(.player1) > set.forPlayer(.player2))
                            Text("\(set.forPlayer(.player2))").bold(set.forPlayer(.player1) < set.forPlayer(.player2))
                        }
                    }
                    VStack {
                        Text("\(score.score.player1)").bold(score.score.player1 > score.score.player2)
                        Text("\(score.score.player2)").bold(score.score.player1 < score.score.player2)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                                
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .foregroundStyle(.primary)
            }        
            .padding(.horizontal)
            .foregroundStyle(.primary)
        }
    }
}


#Preview {
    SyncedScore.shared.score = Score(game: Game.fake())
    return CurrentGameView()
}
