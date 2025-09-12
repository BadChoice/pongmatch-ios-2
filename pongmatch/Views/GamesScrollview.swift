import SwiftUI

struct GamesScrollview : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @Namespace private var namespace
    
    let games:[Game]
    
    var body: some View {
        ScrollView(.horizontal){
            if games.isEmpty {
                Text("No games")
                    .foregroundStyle(.secondary)
                //ContentUnavailableView("No games", systemImage: "trophy.fill")
            } else {
                HStack{
                    ForEach(games, id:\.id) { game in
                        NavigationLink {
                            GameSummaryView(game: game)
                                .navigationTransition(.zoom(sourceID: "zoom_game_\(game.id!)", in: namespace))
                        } label: {
                            CompactGameView(game: game)
                                .foregroundStyle(.black)
                                .matchedTransitionSource(id: "zoom_game_\(game.id!)", in: namespace)
                        }
                    }
                }
            }
        }
        .padding(.bottom)
    }
}
