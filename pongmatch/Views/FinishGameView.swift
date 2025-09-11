import SwiftUI

struct FinishGameView : View {

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State var uploadingGame = false
    
    let score:Score
        
    var body: some View {
        VStack(spacing:20) {
            
            
            Label("GAME FINISHED", systemImage: "flag.pattern.checkered").font(.largeTitle)
            
            HStack(spacing: 25) {
                /* Label("Standard", systemImage:"bird.fill") */
                Label(score.rankingType.description, systemImage: "trophy.fill")
                Label(score.winningCondition.description, systemImage: "medal.fill")
                    
                
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            HStack {
                UserView(user: score.player1).frame(minWidth: 0, maxWidth: .infinity)
                HStack{
                    Text("\(score.setsResult(for: .player1))")
                    Text("-")
                    Text("\(score.setsResult(for: .player2))")
                }.frame(minWidth: 0, maxWidth: .infinity)
                .font(.largeTitle)
                .bold()
                
                UserView(user: score.player2).frame(minWidth: 0, maxWidth: .infinity)
            }
            
            Spacer()
            
            SetsScoreView (
                score: score,
                player1: .player1,
                player2: .player2
            )
            
            Spacer()
            
            Button{
                dismiss()
            } label:{
                Text("Continue")
            }
            .disabled(uploadingGame)
            
            if score.player2.id != User.unknown().id {
                Button {
                    uploadingGame = true
                    Task {
                        do {
                            let _ = try await auth.api.store(game: Game.fromScore(score))
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
    FinishGameView(score: Score(
        player1: User.me(),
        player2: User.unknown()
    ))
}


