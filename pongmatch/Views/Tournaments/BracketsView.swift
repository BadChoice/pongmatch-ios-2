import SwiftUI

struct BracketsView : View {
    let games:[Game]
    
    var body: some View {
        Text("Brackets View")
    }
}

#Preview {
    BracketsView(games: [
        Game.fake(id: 1, round:1),
        Game.fake(id: 2, round:1),
        Game.fake(id: 3, round:1),
        Game.fake(id: 4, round:1),
        Game.fake(id: 5, round:2),
        Game.fake(id: 6, round:2),
        Game.fake(id: 7, round:3),
    ])
}
