import SwiftUI

struct GamesScrollview : View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var nav: NavigationManager
    
    @State var games:[Game] = []
    
    @State var loading:Bool = false
    
    var body: some View {
        ScrollView(.horizontal){
            Group {
                if loading {
                    ProgressView()
                } else {
                    if games.isEmpty {
                        ContentUnavailableView("No games", systemImage: "throphyfill")
                    }else{
                        HStack{
                            ForEach(games, id:\.id) { game in
                                CompactGameView(game: game)
                            }
                        }
                    }
                }
            }.padding(.bottom)
        }
        .task {
            loading = true
            Task {
                games = (try? await auth.api.games()) ?? []
                loading = false
            }
        }
    }
}
