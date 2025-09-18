import SwiftUI

struct FinishGameView: View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var uploadingGame = false
    
    let game: Game
    
    private var shareURL: URL? {
        guard let id = game.id else { return nil }
        return URL(string: "pongmatch://game/\(id)")
    }
            
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
            
            // Share button
            if let shareURL {
                ShareLink(item: shareURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                        .bold()
                }
            } else {
                // Disabled share button when there is no id yet
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.3))
                    .foregroundStyle(.secondary)
                    .clipShape(.capsule)
                    .bold()
                    .accessibilityHint("Unavailable until the game has an identifier")
            }
            
            Button {
                dismiss()
            } label: {
                Text("Continue")
            }
            .disabled(uploadingGame)
            
            if game.player2.id != User.unknown().id {
                Button {
                    uploadingGame = true
                    Task {
                        do {
                            let newGame = try await auth.api.store(game: game)
                            let _ = try await auth.api.uploadResults(newGame, results: game.results)
                            await MainActor.run {
                                dismiss()
                            }
                        } catch {
                            await MainActor.run { uploadingGame = false }
                        }
                    }
                    
                } label: {
                    if uploadingGame {
                        ProgressView()
                    } else {
                        Label("Upload game", systemImage: "square.and.arrow.up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                            .bold()
                    }
                }
                .disabled(uploadingGame)
            }
        }
        .padding()
    }
}

#Preview {
    FinishGameView(game: Game.fake())
        .environmentObject(AuthViewModel())
}
