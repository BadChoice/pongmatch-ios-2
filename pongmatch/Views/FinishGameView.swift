import SwiftUI
internal import RevoFoundation

struct FinishGameView: View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var uploadGame = ApiAction()
    
    let game: Game
                
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Label("GAME FINISHED", systemImage: "flag.pattern.checkered")
                    .font(.largeTitle)
                    .padding(.top, 4)
                
                HStack(spacing: 25) {
                    Label(game.ranking_type.description, systemImage: RankingType.icon)
                    Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    CompactUserView(user: game.player1, winner: game.winner()?.id == game.player1.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    FinalResult(game.finalResult)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    CompactUserView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Spacer()
                }
                
                if let results = game.results {
                    WinLossBar(
                        me:game.player1,
                        friend: game.player2,
                        wins: results.sum { $0[0] },
                        losses: results.sum { $0[1] },
                        label: "Points ratio"
                    )
                    .padding(.horizontal)
                }
                
                HorizontalSetsScoreView(game: game)
                
                
                Spacer()
                
                
                
                
            }
            .padding(.horizontal, 100)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    discardGame()
                }
                label: {
                    Label("Discard", systemImage: "xmark")
                        .foregroundColor(.red)
                }
                .disabled(uploadGame.loading)
            }
            
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
                    .buttonStyle(.glassProminent)
                    .disabled(uploadGame.loading)
                    
                    if let errorMessage = uploadGame.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .interactiveDismissDisabled(true)
        .padding()
    }
    
    private func discardGame(){
        if !game.hasAnUnknownPlayer() {
            
        }
        ///!game.hasAnUnknownPlayer() => ask if sure if both players are ok and game ranked
        
        SyncedScore.shared.clear()
        dismiss()
    }
    
    private func uploadGameResultsAndDismiss(){
        Task {
            if (await uploadGame.run {
                if game.id == nil {
                    let newGame = try await auth.api.store(game: game)
                    let _ = try await auth.api.uploadResults(newGame, results: game.results)
                } else {
                    let _ = try await auth.api.uploadResults(game, results: game.results)
                }
            }) {
                SyncedScore.shared.clear()
                dismiss()
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
