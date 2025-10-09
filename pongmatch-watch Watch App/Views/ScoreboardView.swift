
import SwiftUI

struct ScoreboardView: View {
    @ObservedObject private var syncedScore = SyncedScore.shared
    @EnvironmentObject private var path: NavigationManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showResetConfirmation = false
    @State private var showFinishConfirmation = false
    @State private var showGameFinished = false
    @State private var playersSwapped:Bool = false
    @State private var motionDetectionEnabled:Bool = false
    
    var newScore:Score?
    
    var player1: Player { playersSwapped ? .player2 : .player1 }
    var player2: Player { playersSwapped ? .player1 : .player2 }
    
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
                        
                        Text(syncedScore.score.game.ranking_type.description + " ·")
                        Text(syncedScore.score.game.winning_condition.description)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        ZStack {
                            AvatarView(user: syncedScore.score.player(player1)).frame(width:40)
                            if syncedScore.score.matchWinner()?.id == syncedScore.score.player(player1).id {
                                Image(systemName:"trophy.fill")
                                    .foregroundStyle(.primary)
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
                            AvatarView(user: syncedScore.score.player(player2)).frame(width:40)
                            if syncedScore.score.matchWinner()?.id == syncedScore.score.player(player2).id {
                                Image(systemName:"trophy.fill")
                                    .foregroundStyle(.primary)
                                    .padding(4)
                                    .background(.green)
                                    .clipShape(.circle)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // SCORE
                    HStack(spacing:18) {
                        ScoreView(
                            score: syncedScore.score,
                            player: player1
                        ).onTapGesture {
                            withAnimation {
                                syncedScore.score.addScore(player: player1)
                                syncedScore.sync()
                            }
                        }
                        
                        ScoreView(
                            score: syncedScore.score,
                            player: player2,
                        ).onTapGesture {
                            withAnimation {
                                syncedScore.score.addScore(player: player2)
                                syncedScore.sync()
                            }
                        }
                    }
                    
                    // BUTTONS
                    HStack(spacing: 24) {
                        /*if syncedScore.score.history.count == 0 {
                            Image(systemName: "arrow.left.arrow.right")
                            .onTapGesture{
                                path.popToRoot()
                                /*withAnimation {
                                    playersSwapped.toggle()
                                }*/
                            }
                        }*/
                        
                        if syncedScore.score.history.count == 0 {
                            Image(systemName: "person.fill.and.arrow.left.and.arrow.right.outward")
                            .onTapGesture{
                                withAnimation {
                                    syncedScore.score.swapServer()
                                    syncedScore.sync()
                                }
                            }
                        }
                        
                        if syncedScore.score.history.count > 0 {
                            Image(systemName: "arrow.uturn.backward").onTapGesture {
                                withAnimation {
                                    syncedScore.score.undo()
                                    syncedScore.sync()
                                }
                            }
                        }
                        
                        if syncedScore.score.redoHistory.count > 0 {
                            Image(systemName: "arrow.uturn.forward").onTapGesture{
                                withAnimation {
                                    syncedScore.score.redo()
                                    syncedScore.sync()
                                }
                            }
                        }
                        
                        if syncedScore.score.matchWinner() != nil {
                            Image(systemName: "flag.pattern.checkered")
                            .onTapGesture{
                                showGameFinished = true
                            }
                        }
                        
                        else if syncedScore.score.winner() != nil {
                            Image(systemName: "play.fill").onTapGesture {
                                withAnimation {
                                    syncedScore.score.startNext()
                                    syncedScore.sync()
                                }
                            }
                        }
                        
                    }
                }
                VStack {
                    Toggle(isOn: $motionDetectionEnabled) {
                        Text("Motion detection")
                    }
                        
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
                            SyncedScore.shared.clear()
                            SyncedScore.shared.sync()
                            dismiss()
                        }
                    }
                }
            }
        }
        /*.motionGestures { count in
            guard motionDetectionEnabled else { return }
            switch count {
            case 1: syncedScore.score.addScore(player: .player1)
            case 2: syncedScore.score.addScore(player: .player2)
            case 3: syncedScore.score.undo()
            default:
                break
            }
            syncedScore.sync()
        }*/
        
        .task {
            if let newScore {
                syncedScore.replace(score: newScore)
                syncedScore.sync()
            }
        }.sheet(isPresented: $showGameFinished) {
            GameFinishedView(game: syncedScore.score.game) {
                showGameFinished = false // Dismiss the sheet
                syncedScore.clear()
                syncedScore.sync()
            }
        }.onChange(of: showGameFinished){ _, _ in
            path.popToRoot()
        }
    }
}

private struct ScoreView : View {
    
    let score:Score
    let player:Player
    
    var body: some View {
        VStack {
            Text("\(score.score.forPlayer(player))")
                .font(.largeTitle)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    (ScoreCombo.isSetPointFor(score, player: player) || ScoreCombo.isWinner(score, player: player)) ? .green : .gray
                )
                .cornerRadius(8)
                .contentTransition(.numericText(value: Double(score.score.forPlayer(player))))
            
                        
            serveDots
        }
    }
    
    private var serveDots : some View {
        Group {
            if score.server == player {
                Group {
                    if score.isAtOneServeEach {
                        Text(" __ ")
                            .background(.white)
                            .frame(height:8)
                            .clipShape(.capsule)
                    } else {
                        HStack {
                            Image(systemName: "circle.fill").font(.system(size: 8))
                            if score.isSecondServe {
                                Image(systemName: "circle.fill").font(.system(size: 8))
                            }
                        }
                    }
                }
                .foregroundStyle(.white)
            } else {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.clear)
            }
        }
    }
}

#Preview(traits:.landscapeLeft) {
    ScoreboardView(score: Score(
        game:Game.fake()
    ))
}

#Preview {
    ScoreboardView(score: Score(
        game:Game.fake()
    )).colorScheme(.dark)
}

