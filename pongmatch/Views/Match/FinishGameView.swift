import SwiftUI
internal import RevoFoundation

struct FinishGameView: View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var uploadGame = ApiAction()
    @State private var showDiscardConfirmation = false
    
    let game: Game
                
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Label("GAME FINISHED", systemImage: "flag.pattern.checkered")
                    .font(.largeTitle)
                    .padding(.vertical, 8)
                
                HStack(spacing: 25) {
                    Label(game.ranking_type.description, systemImage: RankingType.icon)
                    Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    CompactUserView(user: game.safePlayer1, winner: game.isTheWinner(game.safePlayer1))
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    FinalResult(game.finalResult)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    CompactUserView(user: game.safePlayer2, winner: game.isTheWinner(game.safePlayer2))
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Spacer()
                }
                
                Divider().padding(.vertical)
                
                if let results = game.results {
                    WinLossBar(
                        me:game.safePlayer1,
                        friend: game.safePlayer2,
                        wins: results.sum { $0[0] },
                        losses: results.sum { $0[1] },
                        label: "Points ratio"
                    )
                    .padding(.horizontal)
                }
                
                Spacer().frame(height: 10)
                
                HorizontalSetsScoreView(game: game)
                    .padding(.horizontal, 14)
                
                if let errorMessage = uploadGame.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 20) // Adjust height to match toolbar height
            }
            .padding(.horizontal, 130)
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        //.ignoresSafeArea(edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    discardGame()
                }
                label: {
                    Label("Discard",
                          systemImage: game.hasAnUnknownPlayer() ? "checkmark" : "xmark")
                        .foregroundColor(.red)
                }
                .disabled(uploadGame.loading)
            }
            
            ToolbarSpacer(.flexible)
            
            if !game.hasAnUnknownPlayer() {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        uploadGameResultsAndDismiss()
                    } label: {
                        if uploadGame.loading {
                            ProgressView()
                        } else {
                            Label("Upload game", systemImage: "checkmark")
                        }
                    }
                    .buttonStyle(uploadGame.loading ? .glassProminent : .glassProminent)
                    .disabled(uploadGame.loading)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        uploadGameResultsAndRematch()
                    } label: {
                        if uploadGame.loading {
                            ProgressView()
                        } else {
                            Label("Upload and Rematch", systemImage: "checkmark.arrow.trianglehead.counterclockwise")
                        }
                    }
                    .buttonStyle(uploadGame.loading ? .glassProminent : .glassProminent)
                    .disabled(uploadGame.loading)
                }
            } else {
                Button {
                    rematch()
                } label: {
                    if uploadGame.loading {
                        ProgressView()
                    } else {
                        Label("Rematch", systemImage: "repeat")
                    }
                }
                .buttonStyle(.glassProminent)
            }
        }
        //.toolbarBackground(.regularMaterial, for: .bottomBar)
        //.toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .interactiveDismissDisabled(true)
        .padding(.top, 28) // Adjust padding to avoid excessive bottom padding
        .alert("Discard this game?", isPresented: $showDiscardConfirmation) {
            Button("Discard", role: .destructive) {
                SyncedScore.shared.clear()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Both players are known and the game can be ranked. Are you sure you want to discard it?")
        }
    }
    
    private func discardGame(){
        if !game.hasAnUnknownPlayer() {
            showDiscardConfirmation = true
            return
        }
        
        SyncedScore.shared.clear()
        dismiss()
    }
    
    private func uploadGameResultsAndDismiss(){
        Task {
            if await uploadResultsIfNeeded() {
                try? await auth.loadGames()
                SyncedScore.shared.clear()
                dismiss()
            }
        }
    }
    
    private func rematch(){
        let rematchGame = Game(
            id: nil,
            initial_score: game.initial_score,
            ranking_type: game.ranking_type,
            winning_condition: game.winning_condition,
            information: nil,
            date: Date(),
            status: .ongoing,
            results: nil,
            player1: game.safePlayer1,
            player2: game.safePlayer2
        )
        
        // Seed a fresh Score so the presenting Scoreboard continues with it
        let newScore = Score(game: rematchGame)
        SyncedScore.shared.replace(score: newScore)
        SyncedScore.shared.sync()
        
        dismiss()
    }
    
    private func uploadGameResultsAndRematch() {
        Task {
            if await uploadResultsIfNeeded() {
                try? await auth.loadGames()
                
                // Create a new game with the same players and configuration
                let rematchGame = Game(
                    id: nil,
                    initial_score: game.initial_score,
                    ranking_type: game.ranking_type,
                    winning_condition: game.winning_condition,
                    information: nil,
                    date: Date(),
                    status: .ongoing,
                    results: nil,
                    player1: game.safePlayer1,
                    player2: game.safePlayer2
                )
                
                // Seed a fresh Score so the presenting Scoreboard continues with it
                let newScore = Score(game: rematchGame)
                SyncedScore.shared.replace(score: newScore)
                SyncedScore.shared.sync()
                
                dismiss()
            }
        }
    }
    
    // MARK: - Shared upload logic
    private func uploadResultsIfNeeded() async -> Bool {
        await uploadGame.run {
            if game.needsId {
                let newGame = try await auth.api.games.store(game)
                let _ = try await auth.api.games.uploadResults(newGame, results: game.results)
            } else {
                let _ = try await auth.api.games.uploadResults(game, results: game.results)
            }
        }
    }
}

#Preview(traits: . landscapeLeft){
    FinishGameView(game: Game.fake())
        .environmentObject(AuthViewModel())
}

#Preview(traits: . landscapeLeft){
    FinishGameView(game: Game.fake(player1: User.me(), player2: User.me()))
        .environmentObject(AuthViewModel())
}
