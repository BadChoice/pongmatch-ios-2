import SwiftUI

struct ScoreboardView : View {
    
    @State private var score:Score
    
    public init(score: Score) {
        _score = .init(initialValue: score)
    }
    
    var body: some View {
        VStack(spacing: 20){
            HStack(spacing:24) {
                Text("Standard")
                Text("Friendly")
                Text("Best of 3")
            }
            
            HStack (spacing:40) {
                UserView(user: score.player1)
                UserView(user: score.player2)
            }
            
            HStack(alignment:.top, spacing: 40) {
                ScoreboardScoreView(
                    score:score.player1Score,
                    serving:score.serving == 0,
                    isSecondServe:score.isSecondServe
                ).onTapGesture {
                    score.score(player: 0)
                }
                
                ScoreboardScoreView(
                    score:score.player2Score,
                    serving:score.serving == 1,
                    isSecondServe:score.isSecondServe
                ).onTapGesture {
                    score.score(player: 1)
                }
            }
        }
    }
}

struct ScoreboardScoreView: View {
    
    let score:Int
    let serving:Bool
    let isSecondServe:Bool
    
    var body: some View {
        VStack(alignment: .center){
            Text("\(score)")
                .font(.system(size: 50, weight:.bold))
                .frame(width:180, height:180)
                //.padding(28)
                .background(.cyan)
                .cornerRadius(8)
            
            if serving {
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8))
                    if isSecondServe{
                        Image(systemName: "circle.fill").font(.system(size: 8))
                    }
                }
                .frame(width:180)
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .background(.red)
                .clipShape(.capsule)
            }
        }
    }
}


#Preview {
    ScoreboardView(score: Score(
        player1: User(id:1, name: "Jordi Puigdellivol", elo: 1111, avavar: nil),
        player2: User(id:2, name: "Gerard Miralles",    elo: 1111, avavar: nil)
    ))
}
