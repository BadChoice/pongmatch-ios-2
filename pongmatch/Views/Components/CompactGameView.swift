import SwiftUI

struct CompactGameView: View {
    let game:Game
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                Label(game.date.displayForHumans, systemImage: "calendar")
                    .font(.caption)
                Spacer()
                Label(game.status.description, systemImage: game.status.icon)
                    .font(.caption)
            }
            
            HStack() {
                /* Label("Standard", systemImage:"bird.fill") */
                Label(game.ranking_type.description, systemImage: RankingType.icon)
                Spacer()
                Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                    
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            Divider()
            
            HStack(alignment: .center) {
                CompactUserView(user: game.player1, winner: game.winner()?.id == game.player1.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                VStack {
                    FinalResult(game.finalResult)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                CompactUserView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .padding()
        .background(.secondary.opacity(0.1))
        //.background(.white)
        //.glassEffect(.clear.interactive(), in: .rect(cornerRadius: 16))
        //.glassEffect(in: .rect(cornerRadius: 16))
        .cornerRadius(8)
        .frame(width:280)
    }
}

#Preview {
    CompactGameView(game: Game.fake())
}
