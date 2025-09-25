import SwiftUI

struct GamesScrollViewVertical : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @Namespace private var namespace
    
    let games:[Game]
    
    var body: some View {
        Group {
            if games.isEmpty {
                Text("No games")
                    .foregroundStyle(.secondary)
            } else {
                LazyVStack {
                    ForEach(games, id:\.id) { game in
                        NavigationLink {
                            GameSummaryView(game: game)
                                .navigationTransition(.zoom(sourceID: "zoom_game_\(game.id)", in: namespace))
                        } label: {
                            GameRowView(game: game)
                                .foregroundStyle(.primary)
                                .matchedTransitionSource(id: "zoom_game_\(game.id)", in: namespace)
                        }
                        Divider()
                    }
                }
                //.background(.white)
                //.cornerRadius(12)
                //.padding(24)
                
            }
        }//.background(Color(.systemGroupedBackground))
    }
}

struct GameRowView : View {
    let game:Game
    
    var body: some View {
        HStack{
            CompactUserView(user:game.player1)
                .frame(maxWidth: .infinity)
            
            FinalResult(game.finalResult)
            
            CompactUserView(user:game.player2)
                .frame(maxWidth: .infinity)
        }.padding()
    }
}

#Preview {
    GamesScrollViewVertical(games: [
        Game.fake(id: 1),
        Game.fake(id: 2),
        Game.fake(id: 3),
        Game.fake(id: 4),
        Game.fake(id: 5),
    ])
}
