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
                
                if let results = score.game.results, results.count > 0 {
                    Spacer().frame(width:20)
                    HStack {
                        ForEach(results.indices, id: \.self) { idx in
                            let result = results[idx]
                            VStack{
                                Text("\(result[0])")
                                Text("\(result[1])")
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
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
