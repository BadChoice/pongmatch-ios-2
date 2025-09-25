import SwiftUI

struct GamesScrollViewVertical : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @Namespace private var namespace
    
    let games:[Game]
    
    var body: some View {
        ScrollView(.vertical) {
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
                            CompactGameView(game: game)
                                .foregroundStyle(.primary)
                                .matchedTransitionSource(id: "zoom_game_\(game.id)", in: namespace)
                        }
                    }
                }.scrollTargetLayout()
            }
        }
        //.scrollTargetBehavior(.paging)
        .scrollTargetBehavior(.viewAligned)
        //.safeAreaPadding(.horizontal, 20.0)
        .scrollIndicators(.hidden)
        .padding(.bottom)
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
