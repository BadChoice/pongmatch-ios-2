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
                /*HStack(spacing:24) {
                 Text("Standard")
                 Text("Friendly")
                 Text("Best of 3")
                 }*/
                
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
                        score:syncedScore.score.score.player1,
                        isMatchPoint: syncedScore.score.isMatchPointFor(player:.player1),
                        serving:syncedScore.score.server == 0,
                        isSecondServe:syncedScore.score.isSecondServe
                    ).onTapGesture {
                        withAnimation {
                            syncedScore.score.addScore(player: .player1)
                            syncedScore.onScoreUpdated()
                        }
                    }
                    
                    SetsScoreView(score: syncedScore.score)
                    
                    ScoreboardScoreView(
                        score:syncedScore.score.score.player2,
                        isMatchPoint: syncedScore.score.isMatchPointFor(player:.player2),
                        serving:syncedScore.score.server == 1,
                        isSecondServe:syncedScore.score.isSecondServe
                    ).onTapGesture {
                        withAnimation {
                            syncedScore.score.addScore(player: .player2)
                            syncedScore.onScoreUpdated()
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
                                    syncedScore.onScoreUpdated()
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
                                    syncedScore.onScoreUpdated()
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
                                    syncedScore.onScoreUpdated()
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
                syncedScore.onScoreUpdated()
            }
        }
    }
}

struct ScoreboardScoreView: View {
    
    let score:Int
    let isMatchPoint:Bool
    let serving:Bool
    let isSecondServe:Bool
    
    var body: some View {
        VStack(alignment: .center){
            Text("\(score)")
                .font(.system(size: 50, weight:.bold))
                .frame(width:200, height:180)
                .foregroundStyle(.white)
                .background(isMatchPoint ? .green : .black)
                .cornerRadius(8)
            
            if serving {
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8))
                    if isSecondServe{
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
