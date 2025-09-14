import SwiftUI

struct FinishGameView : View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State var uploadingGame = false
    
    let game:Game
            
    var body: some View {
        VStack(spacing:20) {
                        
            Label("GAME FINISHED", systemImage: "flag.pattern.checkered")
                .font(.largeTitle)
                .padding(.top, 4)
            
            HStack(spacing: 25) {
                /* Label("Standard", systemImage:"bird.fill") */
                Label(game.ranking_type.description, systemImage: "trophy.fill")
                Label(game.winning_condition.description, systemImage: "medal.fill")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            HStack {
                CompactUserView(user: game.player1, winner:game.winner()?.id == game.player1.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                FinalResult(game.finalResult)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                CompactUserView(user: game.player2, winner:game.winner()?.id == game.player2.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            
            Spacer()
            
            SetsScoreView2 (game:game)
            
            Spacer()
            
            Button{
                dismiss()
            } label:{
                Text("Continue")
            }
            .disabled(uploadingGame)
            
            if game.player2.id != User.unknown().id {
                Button {
                    uploadingGame = true
                    Task {
                        do {
                            let newGame = try await auth.api.store(game: game)
                            let _ = try await auth.api.uploadResults(game, results:game.results)
                            await MainActor.run {
                                dismiss()
                            }
                        } catch {
                            await MainActor.run { uploadingGame = false }
                        }
                    }
                    
                } label:{
                    if uploadingGame {
                        ProgressView()
                    }else{
                        Label("Upload game", systemImage: "square.and.arrow.up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                            .bold()
                    }
                }.disabled(uploadingGame)
            }
        }.padding()
    }
}

#Preview {
    FinishGameView(game: Game.fake())
}
