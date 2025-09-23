import SwiftUI

struct CompactGameView: View {
    let game:Game
    
    var body: some View {
        VStack {
            HStack() {
                /* Label("Standard", systemImage:"bird.fill") */
                
                Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                Spacer()
                Label(game.ranking_type.description, systemImage: RankingType.icon)
                
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
            .overlay(alignment:.top){
                Group{
                    if game.status != .planned {
                        Label(game.status.description, systemImage: game.status.icon)
                    } else {
                        Text(game.date.compactDisplay)
                    }
                }
                .font(.caption2.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.secondary.opacity(0.2))
                .foregroundStyle(.primary)
                .clipShape(.capsule)
            }
            
            .overlay(alignment:.bottom){
                if game.status != .planned {
                    Text(game.date.compactDisplay)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .offset(y:-16)
                }
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
