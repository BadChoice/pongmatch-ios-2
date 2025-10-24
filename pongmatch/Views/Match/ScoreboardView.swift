import SwiftUI
import ConfettiSwiftUI

@available(macOS 26.0, *)
struct ScoreboardView : View {
    
    @ObservedObject private var syncedScore = SyncedScore.shared
    @Environment(\.dismiss) private var dismiss
            
    var newScore:Score?
    
    @State var playersSwapped:Bool = false
    @State var showFinishGame:Bool = false
    
    @State private var confetti: Int = 0

    var keyHandler          = GamePadInputHandler()
    var volumeButtonHandler = VolumeButtonsHandler()
    
    var player1: Player { playersSwapped ? .player2 : .player1 }
    var player2: Player { playersSwapped ? .player1 : .player2 }
    
    init(score:Score? = nil) {
        newScore = score
    }
    
    var body: some View {
        NavigationStack {
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
                            Label(syncedScore.score.game.initial_score.description, systemImage: InitialScore.icon)
                            Label(syncedScore.score.game.ranking_type.description, systemImage: RankingType.icon)
                            Label(syncedScore.score.game.winning_condition.description, systemImage: WinningCondition.icon)
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
                            
                            VerticalSetsScoreView(
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
                }.ignoresSafeArea(edges: .top)
            }
            .ignoresSafeArea(edges: .top)
            .confettiCannon(
                trigger: $confetti,
                num: 100,
                openingAngle: Angle.degrees(30),
                closingAngle: Angle.degrees(150)
            )
            //.disableSwipeBack()
            .forceOrientation(.landscapeRight)
            .noSleep()
            .ignoresSafeArea(edges: .top) // Extend under nav bar
            .task {
                if let newScore {
                    syncedScore.replace(score: newScore)
                    syncedScore.sync()
                }
                                
                FlicButtonsManager.shared.clickDelegate { button, event in
                    let assignment = FlicAssignment.get()
                    withAnimation {
                        if event == .click && assignment.player1 == button {
                            syncedScore.score.addScore(player: assignment.mode == .courtSide ? player1 : .player1)
                            syncedScore.sync()
                        }
                        
                        if event == .click && assignment.player2 == button {
                            syncedScore.score.addScore(player: assignment.mode == .courtSide ? player2 : .player2)
                            syncedScore.sync()
                        }
                        
                        if event == .hold {
                            syncedScore.score.undo()
                            syncedScore.sync()
                        }
                        
                        if event == .doubleClick {
                            syncedScore.score.redo()
                            syncedScore.sync()
                        }
                        
                        if syncedScore.score.winner() != nil {
                            confetti += 1
                        }
                    }
                }
            }
            .background {
                KeyCommandHandler { key in
                    keyHandler.onInput(key)
                    if syncedScore.score.winner() != nil {
                        confetti += 1
                    }
                }
            }
            .onVolumeButtons(
                up:   {
                    withAnimation {
                        volumeButtonHandler.onButtonPressed()
                        if syncedScore.score.winner() != nil {
                            confetti += 1
                        }
                    }
                },
                down: {
                    withAnimation {
                        volumeButtonHandler.onButtonPressed()
                        if syncedScore.score.winner() != nil {
                            confetti += 1
                        }
                    }
                }
            )
            .sheet(isPresented: $showFinishGame) {
                dismiss()
            } content: {
                FinishGameView(game:syncedScore.score.game.finish(syncedScore.score))
                    .presentationDetents([.medium, .large]) // Bottom sheet style
                    .presentationDragIndicator(.visible)    // Show the small slider on top
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button("", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink {
                            WatchSyncInfoView()
                        } label: {
                            Label("Watch Sync", systemImage: "applewatch")
                        }
                        
                        NavigationLink {
                            SetupFlicButtons()
                        } label: {
                            Label("Setup flic buttons", systemImage: "circle.grid.3x3.fill")
                        }
                        
                        NavigationLink {
                            ExternalButtonInfoView()
                        } label: {
                            Label("External buttons", systemImage: "button.horizontal.top.press")                            
                        }
                                                
                        Button("Stop Scoreboard", systemImage: "stop.fill") {
                            dismiss()
                            syncedScore.clear()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .shake(intensity: (ScoreCombo.isMatchPoint(syncedScore.score)) ? 1 : 0, speed: 6, axis: .horizontal)
            .shake(intensity: (ScoreCombo.isMatchPoint(syncedScore.score)) ? 1 : 0, speed: 7, axis: .vertical)
        }
    }
}

struct BackgroundBlurredImage : View {
    
    let user:User?
    let alpha:Double
    let blur:Double
    
    init(user:User?, alpha:Double = 0.10, blur:Double = 20.0) {
        self.user = user
        self.alpha = alpha
        self.blur = blur
    }
            
    var body: some View {
        if let url = user?.photoUrl {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .blur(radius: blur)
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
        if syncedScore.score == nil {
            EmptyView()
        } else {
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
                    
                    if syncedScore.score.history.count == 0 {
                        Image(systemName: "person.fill.and.arrow.left.and.arrow.right.outward")
                            .frame(width: 50.0, height: 50.0)
                            .contentShape(Rectangle())
                            .glassEffect()
                            .glassEffectID("reset", in: namespace)
                            .glassEffectUnion(id: "1", namespace: namespace)
                            .onTapGesture{
                                withAnimation {
                                    syncedScore.score.swapServer()
                                    syncedScore.sync()
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
}

struct ScoreboardScoreView: View {
    
    let score:Score
    let player:Player
    
    var body: some View {
        VStack(alignment: .center){
            Text("\(score.score.forPlayer(player))")
                .font(.system(size: 90, weight:.bold))
                .frame(width:200, height:180)
                .foregroundStyle(.white)
                .background(
                    (ScoreCombo.isSetPointFor(score, player: player) || ScoreCombo.isWinner(score, player: player)) ? .green : Color.accentColor
                )
                .cornerRadius(8)
                .contentTransition(.numericText(value: Double(score.score.forPlayer(player))))
            
            serveDots
        }
        .padding(.top, 24)
        .overlay(alignment:.top){
            ComboBadgeView(combo: ScoreCombo.getCombo(for: score, player: player))
                .offset(y:-8)
        }
        .shake(intensity: (ScoreCombo.isSetPointFor(score, player: player)) ? 1 : 0, speed: 6, axis: .horizontal)
        .shake(intensity: (ScoreCombo.isSetPointFor(score, player: player)) ? 1 : 0, speed: 7, axis: .vertical)
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
                    }
                    else{
                        HStack {
                            Image(systemName: "circle.fill").font(.system(size: 8))
                            if score.isSecondServe {
                                Image(systemName: "circle.fill").font(.system(size: 8))
                            }
                        }
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

struct VerticalSetsScoreView : View {
    let score:Score
    
    let player1:Player
    let player2:Player
    
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
