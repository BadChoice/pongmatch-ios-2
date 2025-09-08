import SwiftUI

struct GameView: View {
    let game:Game
    
    var body: some View {
        VStack (alignment: .leading){
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "calendar")
                    Text(game.date.displayForHumans)
                }.font(.caption2)
                
                if let info = game.information{
                    Text(info).font(.subheadline)
                }
            }
            
            HStack(alignment: .center) {
                CompactUserView(user: User.me())
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                Text("VS")
                    .font(.largeTitle)
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                CompactUserView(user: User.unknown())
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
        .frame(width:250)
    }
}

#Preview {
    GameView(game: Game(
        id: 1,
        information: "A nice game",
        date: Date(),
        status: .planned,
        created_at: Date(),
        updated_at: nil
    ))
}
