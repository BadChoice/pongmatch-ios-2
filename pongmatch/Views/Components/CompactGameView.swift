import SwiftUI

struct CompactGameView: View {
    let game:Game
    
    var body: some View {
        VStack (alignment: .leading){
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "calendar")
                    Text(game.date.displayForHumans)
                    Spacer()
                    Label(game.status.description, systemImage: game.status.icon)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            
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
                
                Group {
                    FinalResult(game.finalResult)                    
                }.font(.largeTitle)
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                CompactUserView(user: game.player2, winner: game.winner()?.id == game.player2.id)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            
            
            
            Divider()
            
            Text(game.information ?? "")
                .lineLimit(2, reservesSpace: true)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
        }
        .padding()
        .background(.gray.opacity(0.1))
        //.background(.white)
        //.glassEffect(.clear.interactive(), in: .rect(cornerRadius: 16))
        //.glassEffect(in: .rect(cornerRadius: 16))
        //.cornerRadius(8)
        .frame(width:290)
    }
}

#Preview {
    CompactGameView(game: Game.fake())
}
