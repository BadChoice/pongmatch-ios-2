import SwiftUI

struct GamesScrollview : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
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
                        } label: {
                            CompactGameView(game: game)
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
        }
        .padding(.bottom)
    }
}
