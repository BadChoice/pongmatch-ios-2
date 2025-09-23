import SwiftUI
internal import RevoFoundation

struct FinishGameView: View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var uploadGame = ApiAction()
    
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
                    CompactUserView(user: game.player1, winner: game.winner()?.id == game.player1.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    FinalResult(game.finalResult)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    CompactUserView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Spacer()
                }
                
                Divider().padding(.vertical)
                
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
                    .buttonStyle(.glassProminent)
                    .disabled(uploadGame.loading)
                }
            }
        }
        //.toolbarBackground(.regularMaterial, for: .bottomBar)
        //.toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .interactiveDismissDisabled(true)
        .padding(.top, 28) // Adjust padding to avoid excessive bottom padding
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
