
import SwiftUI

struct ScoreboardView: View {
    @State private var score:Score
    @State private var showResetConfirmation = false
    @State private var showFinishConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(score:Score) {
        self.score = score
    }
    
    var body: some View {
        TabView {
            VStack {
                // HEADER
                HStack(spacing: 20) {
                    ZStack {
                        AvatarView(user: score.player1).frame(width:40)
                        if score.matchWinner()?.id == score.player1.id {
                            Image(systemName:"trophy.fill")
                                .foregroundStyle(.black)
                                .padding(4)
                                .background(.green)
                                .clipShape(.circle)
                        }
                    }
                    
                    HStack {
                        Text("\(score.setsResult.0)")
                        Text("-")
                        Text("\(score.setsResult.1)")
                    }
                    
                    ZStack {
                        AvatarView(user: score.player2).frame(width:40)
                        if score.matchWinner()?.id == score.player2.id {
                            Image(systemName:"trophy.fill")
                                .foregroundStyle(.black)
                                .padding(4)
                                .background(.green)
                                .clipShape(.circle)
                        }
                    }
                }
                
                Spacer()
                
                // SCORE
                HStack(spacing:20) {
                    ScoreView(
                        score: score.score.0,
                        matchPoint:score.isMatchPointFor(player:0),
                        serving:score.server == 0,
                        secondServe:score.isSecondServe,
                    ).onTapGesture {
                        withAnimation { score.addScore(player: 0) }
                    }
                    
                    ScoreView(
                        score: score.score.1,
                        matchPoint:score.isMatchPointFor(player:1),
                        serving:score.server == 1,
                        secondServe:score.isSecondServe,
                    ).onTapGesture {
                        withAnimation { score.addScore(player: 1) }
                    }
                }
                
                // BUTTONS
                HStack(spacing: 12) {
                    if score.history.count > 0 {
                        Image(systemName: "arrow.uturn.backward").onTapGesture {
                            withAnimation { score.undo() }
                        }
                    }
                    
                    if score.winner() != nil {
                        Image(systemName: "play.fill").onTapGesture {
                            withAnimation { score.startNext() }
                        }
                    }
                    
                }
            }
            VStack{
                Button("Reset") {
                    showResetConfirmation = true
                }.alert("Are you sure you want to reset?", isPresented: $showResetConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        score.reset()
                    }
                }
                Button("Finish"){
                    showFinishConfirmation = true
                }.alert("Are you sure you want to finish?", isPresented: $showFinishConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Finish", role: .destructive) {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct ScoreView : View {
    
    let score:Int
    let matchPoint:Bool
    let serving:Bool
    let secondServe:Bool
    
    var body: some View {
        VStack{
            Text("\(score)")
                .font(.largeTitle)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(matchPoint ? .green : .gray)
                .cornerRadius(8)
            
                        
            if serving {
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8))
                    if secondServe {
                        Image(systemName: "circle.fill").font(.system(size: 8))
                    }
                }
                .foregroundStyle(.white)
            }else{
                Image(systemName: "circle.fill").font(.system(size: 8)).foregroundStyle(.black)
            }
            
        }
    }
}

#Preview {
    ScoreboardView(score: Score(
        player1: User.me(),
        player2: User(id: 2, name: "Gerard Miralles", elo: 1111, avatar: "https://pongmatch.app/img/default-avatar.png")
    ))
}
