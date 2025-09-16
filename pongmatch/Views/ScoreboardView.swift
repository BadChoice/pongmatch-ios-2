import SwiftUI
import ConfettiSwiftUI

@available(macOS 26.0, *)
struct ScoreboardView : View {
    
    @ObservedObject private var syncedScore = SyncedScore.shared
            
    @State var buttonHandler:ScoreButtonHandler?
    var newScore:Score?
    
    @State var playersSwapped:Bool = false
    @State var showFinishGame:Bool = false
    
    @State private var confetti: Int = 0

    
    var player1: Score.Player { playersSwapped ? .player2 : .player1 }
    var player2: Score.Player { playersSwapped ? .player1 : .player2 }
    
    init(score:Score? = nil) {
        newScore = score
    }
    
    var body: some View {
        ZStack {
            BackgroundBlurredImage(user:syncedScore.score?.player1)
            //Color.white.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 14){
                if syncedScore.score == nil {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                else{
                    // Header
                    Spacer().frame(height:20)
                    
                    HStack(spacing: 25) {
                        /* Label("Standard", systemImage:"bird.fill") */
                        Label(syncedScore.score.game.ranking_type.description, systemImage: "trophy.fill")
                        Label(syncedScore.score.game.winning_condition.description, systemImage: "medal.fill")
                            
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                        
                    
                    HStack (spacing:40) {
                        UserView(user: syncedScore.score.player(player1))
                            .frame(width:200)
                        HStack {
                            Text("\(syncedScore.score.setsResult(for:player1))").bold()
                            Text("-")
                            Text("\(syncedScore.score.setsResult(for:player2))").bold()
                        }
                        UserView(user: syncedScore.score.player(player2))
                            .frame(width:200)
                    }
                    
                    
                    // Score
                    HStack(alignment:.top, spacing: 30) {
                        ScoreboardScoreView(
                            score:syncedScore.score,
                            player:player1
                        ).onTapGesture {
                            withAnimation {
                                syncedScore.score.addScore(player: player1)
                                syncedScore.sync()
                                if syncedScore.score.winner() != nil {
                                    confetti += 1
                                }
                            }
                        }
                        
                        SetsScoreView(
                            score: syncedScore.score,
                            player1: player1,
                            player2: player2
                        )
                        
                        ScoreboardScoreView(
                            score:syncedScore.score,
                            player:player2
                        ).onTapGesture {
                            withAnimation {
                                syncedScore.score.addScore(player: player2)
                                syncedScore.sync()
                                if syncedScore.score.winner() != nil {
                                    confetti += 1
                                }
                            }
                        }
                    }.overlay(alignment:.bottom) {
                        ScoreBoardActionsView(syncedScore: syncedScore, playersSwapped: $playersSwapped, showFinishGame: $showFinishGame)
                            .offset(.init(width: 0, height: 30)
                        )
                    }
                }
            }
            .confettiCannon(
                trigger: $confetti,
                num: 100,
                openingAngle: Angle.degrees(30),
                closingAngle: Angle.degrees(150)
            )
            .disableSwipeBack()
            .forceOrientation(.landscapeRight)
            .noSleep()
            .ignoresSafeArea(edges: .top) // Extend under nav bar
            .task {
                if let newScore {
                    syncedScore.replace(score: newScore)
                    syncedScore.sync()
                }
                
                buttonHandler = ScoreButtonHandler {
                    withAnimation {
                        syncedScore.score.addScore(player: .player1)
                        syncedScore.sync()
                        if syncedScore.score.winner() != nil {
                            confetti += 1
                        }
                    }
                } onPlayer2: {
                    withAnimation {
                        syncedScore.score.addScore(player: .player2)
                        syncedScore.sync()
                        if syncedScore.score.winner() != nil {
                            confetti += 1
                        }
                    }
                } onUndo: {
                    withAnimation {
                        syncedScore.score.undo()
                        syncedScore.sync()
                    }
                }
            }
            .background {
                KeyCommandHandler { _ in buttonHandler?.onButtonPressed() }
            }
            .onVolumeButtons(
                up:   { buttonHandler?.onButtonPressed() },
                down: { buttonHandler?.onButtonPressed() }
            )
            .sheet(isPresented: $showFinishGame){
                FinishGameView(game:syncedScore.score.game.finish(syncedScore.score))
                    .presentationDetents([.medium, .large]) // Bottom sheet style
                    .presentationDragIndicator(.visible)    // Show the small slider on top
            }
        }
    }
}

struct BackgroundBlurredImage : View {
    
    let user:User?
    let alpha:Double
    
    init(user:User?, alpha:Double = 0.10) {
        self.user = user
        self.alpha = alpha
    }
            
    var body: some View {
        if let url = Images.avatar(user?.avatar) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 40)
                    .opacity(alpha)
                    .ignoresSafeArea()
            } placeholder: {
                Color.white.ignoresSafeArea()
            }
        }
    }
}



struct ScoreBoardActionsView:View {
    
    @ObservedObject var syncedScore:SyncedScore
    @State private var showResetConfirmation = false
    @Binding var playersSwapped:Bool
    
    @Environment(\.dismiss) private var dismiss
    
    @Namespace private var namespace
    
    @Binding var showFinishGame:Bool
    
    
    var body: some View {
        GlassEffectContainer(spacing: 40.0) {
            HStack {
                if syncedScore.score.history.count == 0 {
                    Image(systemName: "arrow.left.arrow.right")
                    .frame(width: 50.0, height: 50.0)
                    .contentShape(Rectangle())
                    .glassEffect()
                    .glassEffectID("reset", in: namespace)
                    .glassEffectUnion(id: "1", namespace: namespace)
                    .onTapGesture{
                        withAnimation {
                            playersSwapped.toggle()
                        }
                    }
                }
                
                if syncedScore.score.history.count > 0 || syncedScore.score.sets.count > 0 {
                    Image(systemName: "trash")
                    .frame(width: 50.0, height: 50.0)
                    .contentShape(Rectangle())
                    .glassEffect()
                    .glassEffectID("reset", in: namespace)
                    .glassEffectUnion(id: "1", namespace: namespace)
                    .onTapGesture{
                        showResetConfirmation = true
                    }
                    .alert("Are you sure you want to reset?", isPresented: $showResetConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Reset", role: .destructive) {
                            syncedScore.score.reset()
                            syncedScore.sync()
                        }
                    }
                    
                }
                
                if syncedScore.score.history.count > 0 {
                    Image(systemName: "arrow.uturn.backward")
                    .frame(width: 50.0, height: 50.0)
                    .contentShape(Rectangle())
                    .glassEffect()
                    .glassEffectID("undo", in: namespace)
                    .glassEffectUnion(id: "1", namespace: namespace)
                    .onTapGesture{
                        withAnimation {
                            syncedScore.score.undo()
                            syncedScore.sync()
                        }
                    }
                }
                
                if syncedScore.score.redoHistory.count > 0 {
                    Image(systemName: "arrow.uturn.forward")
                    .frame(width: 50.0, height: 50.0)
                    .contentShape(Rectangle())
                    .glassEffect()
                    .glassEffectID("redo", in: namespace)
                    .glassEffectUnion(id: "1", namespace: namespace)
                    .onTapGesture{
                        withAnimation {
                            syncedScore.score.redo()
                            syncedScore.sync()
                        }
                    }
                }
                
                if syncedScore.score.matchWinner() != nil {
                    Image(systemName: "flag.pattern.checkered")
                    .frame(width: 70.0, height: 70.0)
                    .contentShape(Rectangle())
                    .glassEffect()
                    .glassEffectID("next", in: namespace)
                    .glassEffectUnion(id: "2", namespace: namespace)
                    .onTapGesture{
                        showFinishGame = true
                        //dismiss()
                    }
                }
                
                else if syncedScore.score.winner() != nil {
                    Image(systemName: "play.fill")
                    .frame(width: 70.0, height: 70.0)
                    .contentShape(Rectangle())
                    .glassEffect()
                    .glassEffectID("next", in: namespace)
                    .glassEffectUnion(id: "2", namespace: namespace)
                    .onTapGesture{
                        withAnimation {
                            syncedScore.score.startNext()
                            syncedScore.sync()
                        }
                    }
                }
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
    
    let player1:Score.Player
    let player2:Score.Player
    
    var body: some View {
        VStack {
            ForEach(score.sets.indices, id: \.self) { index in
                let set = score.sets[index]
                HStack {
                    Text("\(set.forPlayer(player1))")
                    Text("-")
                    Text("\(set.forPlayer(player2))")
                }.foregroundStyle(.gray)
            }
        }
    }
}


#Preview {
    if #available(macOS 26.0, *) {
        ScoreboardView(score: Score(game: Game.fake()))
    }
}
