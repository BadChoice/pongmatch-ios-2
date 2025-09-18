import SwiftUI

struct GameFinishedView : View {
    
    @ObservedObject private var syncedScore = SyncedScore.shared
    @Environment(\.dismiss) private var dismiss
    
    var onContinue: (() -> Void)? = nil
    
    var game:Game {
        syncedScore.score.game
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                Label("Game finished", systemImage: "flag.checkered")
                    .padding()
                
                HStack(spacing: 10) {
                    AvatarView(user: game.player1, winner: game.winner()?.id == game.player1.id)
                        .frame(width:40)
                    if let finalResult = game.finalResult {
                        Text("\(finalResult[0])")
                        Text("-")
                        Text("\(finalResult[1])")
                    }
                    AvatarView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                        .frame(width:40)
                }
                .font(.largeTitle)
                .fontWeight(.medium)
                
                HStack {
                    Label(game.ranking_type.description, systemImage: RankingType.icon)
                    Spacer()
                    Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                }
                .padding()
                .font(.footnote)
                .foregroundStyle(.secondary)
                
                Divider().padding()
                
                if let sets = game.results {
                    HStack(spacing:12) {
                        Spacer()
                        VStack{
                            AvatarView(user: game.player1, winner: game.winner()?.id == game.player1.id)
                                .frame(width:20)
                            AvatarView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                                .frame(width:20)
                        }
                        ForEach(sets.indices, id: \ .self) { idx in
                            VStack(spacing:4) {
                                Text("\(sets[idx][0])").bold(sets[idx][0] > sets[idx][1])
                                Text("\(sets[idx][1])").bold(sets[idx][0] < sets[idx][1])
                            }
                        }
                        Spacer()
                    }
                    
                    Divider().padding()
                }
                
                if !syncedScore.score.game.hasAnUnknownPlayer(){
                    Button("Upload results") {
                        syncedScore.finishedOnWatch()
                        onContinue?()
                    }
                }
                
                Button("Continue") {
                    onContinue?()
                }
            }
        }
    }
}

#Preview {
    SyncedScore.shared.score = Score(game: Game.fake())
    return GameFinishedView()
}
