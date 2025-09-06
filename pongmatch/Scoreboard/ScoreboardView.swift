import SwiftUI

@available(macOS 26.0, *)
struct ScoreboardView : View {
    
    @State private var score:Score
    
    @Namespace private var namespace
    
    public init(score: Score) {
        _score = .init(initialValue: score)
    }
    
    var body: some View {
        VStack(spacing: 14){
            
            // Header
            /*HStack(spacing:24) {
                Text("Standard")
                Text("Friendly")
                Text("Best of 3")
            }*/
            
            HStack (spacing:40) {
                UserView(user: score.player1).frame(width:200)
                HStack {
                    Text("\(score.setsResult.0)")
                    Text("-")
                    Text("\(score.setsResult.1)")
                }
                UserView(user: score.player2).frame(width:200)
            }
            
            
            // Score
            HStack(alignment:.top, spacing: 30) {
                ScoreboardScoreView(
                    score:score.score.0,
                    isMatchPoint: score.isMatchPointForPlayer1,
                    serving:score.server == 0,
                    isSecondServe:score.isSecondServe
                ).onTapGesture {
                    withAnimation {
                        score.addScore(player: 0)
                    }
                }
                
                SetsScoreView(score: score)
                
                ScoreboardScoreView(
                    score:score.score.1,
                    isMatchPoint: score.isMatchPointForPlayer2,
                    serving:score.server == 1,
                    isSecondServe:score.isSecondServe
                ).onTapGesture {
                    withAnimation {
                        score.addScore(player: 1)
                    }
                }
            }
            
            // Bottom bar
            GlassEffectContainer(spacing: 40.0) {
                HStack {
                    if score.history.count > 0 || score.sets.count > 0 {
                        Image(systemName: "trash").onTapGesture{
                            withAnimation { score.reset() }
                        }
                        .frame(width: 40.0, height: 40.0)
                        .glassEffect()
                        .glassEffectID("reset", in: namespace)
                        .glassEffectUnion(id: "1", namespace: namespace)

                    }
                    
                    if score.history.count > 0 {
                        Image(systemName: "arrow.uturn.backward").onTapGesture{
                            withAnimation { score.undo() }
                        }
                        .frame(width: 40.0, height: 40.0)
                        .glassEffect()
                        .glassEffectID("undo", in: namespace)
                        .glassEffectUnion(id: "1", namespace: namespace)

                    }

                    if score.winner() != nil {
                        Image(systemName: "play.fill").onTapGesture{
                            withAnimation { score.startNext() }
                        }
                        .frame(width: 50.0, height: 50.0)
                        .glassEffect()
                        .glassEffectID("next", in: namespace)
                        .glassEffectUnion(id: "2", namespace: namespace)
                    }
                }
            }
        }
    }
}

struct ScoreboardScoreView: View {
    
    let score:Int
    let isMatchPoint:Bool
    let serving:Bool
    let isSecondServe:Bool
    
    var body: some View {
        VStack(alignment: .center){
            Text("\(score)")
                .font(.system(size: 50, weight:.bold))
                .frame(width:200, height:180)
                .foregroundStyle(.white)
                .background(isMatchPoint ? .green : .black)
                .cornerRadius(8)
            
            if serving {
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8))
                    if isSecondServe{
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
    
    var body: some View {
        VStack {
            ForEach(score.sets.indices, id: \.self) { index in
                let set = score.sets[index]
                HStack {
                    Text("\(set.0)")
                    Text("-")
                    Text("\(set.1)")
                }
            }
        }
    }
    
}


#Preview {
    if #available(macOS 26.0, *) {
        ScoreboardView(score: Score(
            player1: User.me(),
            player2: User(id:2, name: "Gerard Miralles",    elo: 1111, avatar: "https://pongmatch.app/img/default-avatar.png")
        ))
    }
}
