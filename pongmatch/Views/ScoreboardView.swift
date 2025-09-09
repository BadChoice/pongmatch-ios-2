import SwiftUI

@available(macOS 26.0, *)
struct ScoreboardView : View {
    
    @ObservedObject private var syncedScore = SyncedScore.shared
    
    @Namespace private var namespace
    @State private var showResetConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    
    var newScore:Score?
    
    init(score:Score? = nil) {
        newScore = score
    }
    
    var body: some View {
        VStack(spacing: 14){
            if syncedScore.score == nil {
                ProgressView()
            }
            else{
                // Header
                
                HStack(spacing: 30) {
                    Text("Standard")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Friendly")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text(syncedScore.score.winningCondition.description)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                    
                
                HStack (spacing:40) {
                    UserView(user: syncedScore.score.player1).frame(width:200)
                    HStack {
                        Text("\(syncedScore.score.setsResult.player1)").bold()
                        Text("-")
                        Text("\(syncedScore.score.setsResult.player2)").bold()
                    }
                    UserView(user: syncedScore.score.player2).frame(width:200)
                }
                
                
                // Score
                HStack(alignment:.top, spacing: 30) {
                    ScoreboardScoreView(
                        score:syncedScore.score,
                        player:.player1
                    ).onTapGesture {
                        withAnimation {
                            syncedScore.score.addScore(player: .player1)
                            syncedScore.sync()
                        }
                    }
                    
                    SetsScoreView(score: syncedScore.score)
                    
                    ScoreboardScoreView(
                        score:syncedScore.score,
                        player:.player2
                    ).onTapGesture {
                        withAnimation {
                            syncedScore.score.addScore(player: .player2)
                            syncedScore.sync()
                        }
                    }
                }
                
                // Bottom bar
                GlassEffectContainer(spacing: 40.0) {
                    HStack {
                        if syncedScore.score.history.count > 0 || syncedScore.score.sets.count > 0 {
                            Image(systemName: "trash").onTapGesture{
                                showResetConfirmation = true
                            }
                            .alert("Are you sure you want to reset?", isPresented: $showResetConfirmation) {
                                Button("Cancel", role: .cancel) {}
                                Button("Reset", role: .destructive) {
                                    syncedScore.score.reset()
                                    syncedScore.sync()
                                }
                            }
                            .frame(width: 40.0, height: 40.0)
                            .glassEffect()
                            .glassEffectID("reset", in: namespace)
                            .glassEffectUnion(id: "1", namespace: namespace)
                            
                        }
                        
                        if syncedScore.score.history.count > 0 {
                            Image(systemName: "arrow.uturn.backward").onTapGesture{
                                withAnimation {
                                    syncedScore.score.undo()
                                    syncedScore.sync()
                                }
                            }
                            .frame(width: 40.0, height: 40.0)
                            .glassEffect()
                            .glassEffectID("undo", in: namespace)
                            .glassEffectUnion(id: "1", namespace: namespace)
                            
                        }
                        
                        if syncedScore.score.matchWinner() != nil {
                            Image(systemName: "flag.pattern.checkered").onTapGesture{
                                dismiss()
                            }
                            .frame(width: 50.0, height: 50.0)
                            .glassEffect()
                            .glassEffectID("next", in: namespace)
                            .glassEffectUnion(id: "2", namespace: namespace)
                        }
                        
                        else if syncedScore.score.winner() != nil {
                            Image(systemName: "play.fill").onTapGesture{
                                withAnimation {
                                    syncedScore.score.startNext()
                                    syncedScore.sync()
                                }
                            }
                            .frame(width: 50.0, height: 50.0)
                            .glassEffect()
                            .glassEffectID("next", in: namespace)
                            .glassEffectUnion(id: "2", namespace: namespace)
                        }
                    }
                }
            }
        }
        .task {
            if let newScore {
                syncedScore.replace(score: newScore)
                syncedScore.sync()
            }
        }
    }
}

struct ScoreboardScoreView: View {
    
    let score:Score
    let player:Score.Player
    
    var body: some View {
        VStack(alignment: .center){
            Text("\(score.score.forPlayer(player))")
                .font(.system(size: 50, weight:.bold))
                .frame(width:200, height:180)
                .foregroundStyle(.white)
                .background(score.isMatchPointFor(player: player) ? .green : .black)
                .cornerRadius(8)
                .contentTransition(.numericText(value: Double(score.score.forPlayer(player))))
            
            if score.server == player {
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8))
                    if score.isSecondServe {
                        Image(systemName: "circle.fill").font(.system(size: 8))
                    }
                }
                .frame(width:200)
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .background(.red)
                .clipShape(.capsule)
            }
        }
    }
}

struct SetsScoreView : View {
    let score:Score
    
    var body: some View {
        VStack {
            ForEach(score.sets.indices, id: \.self) { index in
                let set = score.sets[index]
                HStack {
                    Text("\(set.player1)")
                    Text("-")
                    Text("\(set.player2)")
                }
            }
        }
    }
}


#Preview {
    if #available(macOS 26.0, *) {
        ScoreboardView(score: Score(
            player1: User.me(),
            player2: User.unknown()
        ))
    }
}
