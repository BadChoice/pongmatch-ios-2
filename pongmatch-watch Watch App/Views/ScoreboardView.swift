
import SwiftUI

struct ScoreboardView: View {
    @ObservedObject private var syncedScore = SyncedScore.shared
    @State private var showResetConfirmation = false
    @State private var showFinishConfirmation = false
    
    var newScore:Score?
    
    @Environment(\.dismiss) private var dismiss
    
    init(score:Score? = nil) {
        newScore = score
    }
    
    var body: some View {
        TabView {
            if syncedScore.score == nil {
                ProgressView()
            }
            else{
                VStack {
                    // HEADER
                    HStack() {
                        /*Text("Standard ·")
                            .font(.footnote)
                            .foregroundColor(.secondary)*/
                        
                        Text(syncedScore.score.rankingType.description + " ·")
                        Text(syncedScore.score.winningCondition.description)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        ZStack {
                            AvatarView(user: syncedScore.score.player1).frame(width:40)
                            if syncedScore.score.matchWinner()?.id == syncedScore.score.player1.id {
                                Image(systemName:"trophy.fill")
                                    .foregroundStyle(.black)
                                    .padding(4)
                                    .background(.green)
                                    .clipShape(.circle)
                            }
                        }
                        
                        HStack {
                            Text("\(syncedScore.score.setsResult.player1)")
                            Text("-")
                            Text("\(syncedScore.score.setsResult.player2)")
                        }
                        
                        ZStack {
                            AvatarView(user: syncedScore.score.player2).frame(width:40)
                            if syncedScore.score.matchWinner()?.id == syncedScore.score.player2.id {
                                Image(systemName:"trophy.fill")
                                    .foregroundStyle(.black)
                                    .padding(4)
                                    .background(.green)
                                    .clipShape(.circle)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // SCORE
                    HStack(spacing:20) {
                        ScoreView(
                            score: syncedScore.score,
                            player:.player1
                        ).onTapGesture {
                            withAnimation {
                                syncedScore.score.addScore(player: .player1)
                                syncedScore.sync()
                            }
                        }
                        
                        ScoreView(
                            score: syncedScore.score,
                            player: .player2,
                        ).onTapGesture {
                            withAnimation {
                                syncedScore.score.addScore(player: .player2)
                                syncedScore.sync()
                            }
                        }
                    }
                    
                    // BUTTONS
                    HStack(spacing: 12) {
                        if syncedScore.score.history.count > 0 {
                            Image(systemName: "arrow.uturn.backward").onTapGesture {
                                withAnimation {
                                    syncedScore.score.undo()
                                    syncedScore.sync()
                                }
                            }
                        }
                        
                        if syncedScore.score.winner() != nil {
                            Image(systemName: "play.fill").onTapGesture {
                                withAnimation {
                                    syncedScore.score.startNext()
                                    syncedScore.sync()
                                }
                            }
                        }
                        
                    }
                }
                VStack{
                    Button("Reset") {
                        showResetConfirmation = true
                    }.alert("Are you sure you want to reset?", isPresented: $showResetConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Reset", role: .destructive) {
                            withAnimation{
                                syncedScore.score.reset()
                                syncedScore.sync()
                            }
                        }
                    }
                    Button("Finish"){
                        showFinishConfirmation = true
                    }.alert("Are you sure you want to finish?", isPresented: $showFinishConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Finish", role: .destructive) {
                            dismiss()
                        }
                    }
                }
            }
        }.task {
            if let newScore {
                syncedScore.replace(score: newScore)
                syncedScore.sync()
            }
        }
    }
}

private struct ScoreView : View {
    
    let score:Score
    let player:Score.Player
    
    var body: some View {
        VStack{
            Text("\(score.score.forPlayer(player))")
                .font(.largeTitle)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(score.isMatchPointFor(player: player) ? .green : .gray)
                .cornerRadius(8)
                .contentTransition(.numericText(value: Double(score.score.forPlayer(player))))
            
                        
            if score.server == player {
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8))
                    if score.isSecondServe {
                        Image(systemName: "circle.fill").font(.system(size: 8))
                    }
                }
                .foregroundStyle(.white)
            }else{
                Image(systemName: "circle.fill").font(.system(size: 8)).foregroundStyle(.black)
            }
            
        }
    }
}

#Preview {
    ScoreboardView(score: Score(
        player1: User.me(),
        player2: User.unknown()
    ))
}
