import SwiftUI

struct FinishGameView: View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var uploadGame = ApiAction()
    
    let game: Game
                
    var body: some View {
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
                CompactUserView(user: game.player1, winner: game.winner()?.id == game.player1.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                FinalResult(game.finalResult)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                CompactUserView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            
            Spacer()
            
            SetsScoreView2(game: game)
            
            Spacer()

            
            Button {
                dismiss()
            } label: {
                Text("Continue")
            }
            .disabled(uploadGame.loading)
            
            if !game.hasAnUnknownPlayer() {
                Button {
                    Task {
                        if (await uploadGame.run {
                            let newGame = try await auth.api.store(game: game)
                            let _ = try await auth.api.uploadResults(newGame, results: game.results)
                        }) {
                            dismiss()
                        }
                    }
                } label: {
                    if uploadGame.loading {
                        ProgressView()
                    } else {
                        Label("Upload game", systemImage: "square.and.arrow.up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                            .bold()
                    }
                }
                .disabled(uploadGame.loading)
                
                if let errorMessage = uploadGame.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
    }
}

#Preview {
    FinishGameView(game: Game.fake())
        .environmentObject(AuthViewModel())
}
