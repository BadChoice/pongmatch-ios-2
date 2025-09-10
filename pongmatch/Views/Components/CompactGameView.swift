import SwiftUI

struct CompactGameView: View {
    let game:Game
    
    var body: some View {
        VStack (alignment: .leading){
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "calendar")
                    Text(game.date.displayForHumans)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            
            HStack() {
                /* Label("Standard", systemImage:"bird.fill") */
                Label(game.ranking_type.description, systemImage: "trophy.fill")
                Spacer()
                Label(game.winning_condition.description, systemImage: "medal.fill")
                    
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            Divider()
            
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
            
            
            
            Divider()
            
            Text(game.information ?? "")
                .lineLimit(2, reservesSpace: true)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
        .frame(width:250)
    }
}

#Preview {
    CompactGameView(game: Game(
        id: 1,
        ranking_type: .competitive,
        winning_condition: .bestof3,
        information: "A nice game",
        date: Date(),
        status: .planned,
        results:[["11","8"], ["7","11"], ["11","5"]]
    ))
}
