import SwiftUI

struct GameSummaryView : View {
    let game:Game
    
    @Namespace private var namespace
    
    var body: some View {
        VStack {
                 
            VStack(spacing: 10) {
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
                    Label(game.ranking_type.description, systemImage: "trophy.fill")
                    Spacer()
                    Label(game.winning_condition.description, systemImage: "medal.fill")
                    
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                NavigationLink {
                    FriendView(user: game.player1)
                        .navigationTransition(.zoom(sourceID: "zoom_user_\(game.player1.id)", in: namespace))
                } label: {
                    CompactUserView(user: game.player1, winner:game.winner()?.id == game.player1.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .matchedTransitionSource(id: "zoom_user_\(game.player1.id)", in: namespace)
                }
                if let finalResult = game.finalResult{
                    HStack {
                        Text("\(finalResult[0]) - \(finalResult[1])")
                    }.font(.largeTitle.bold())
                    
                }
                NavigationLink {
                    FriendView(user: game.player2)
                        .navigationTransition(.zoom(sourceID: "zoom_user_\(game.player2.id)", in: namespace))
                } label: {
                    CompactUserView(user: game.player2, winner:game.winner()?.id == game.player2.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .matchedTransitionSource(id: "zoom_user_\(game.player2.id)", in: namespace)
                }
            }
            .foregroundStyle(.black)
            .padding(.vertical, 20)
            
            Divider()
            
            if game.isFinished() {
                VStack(alignment: .leading) {
                    Text("Sets").font(.title2)
                    ResultsTableView(game:game)
                }
                .padding()
            }
            
            // https://ttcup.com/videos/4558453588f55d5aa02ddf8dd46deefc66f086f3/
            // Winning percentage per own server per set
            // Set time
            // Match time
            // Points percentage per set and overall
            // Max consecutive points strike per set and overall
            // Set history table
            
            HStack {
                if game.isFinished() {
                    Button("Share", systemImage: "square.and.arrow.up") { }
                } else {
                    Button("Add to calendar", systemImage: "calendar.badge.plus") { }
                }
                
            }
            Spacer()
        }
    }
}

struct ResultsTableView: View {
    let game:Game
    
    let results = [[11, 3, 11], [2, 11, 4], [11, 8, 11]]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 20) {
                AvatarView(user: game.player1).frame(width: 30)
                ForEach(results, id: \.self) { set in
                    Text("\(set[0])").bold(set[0] > set[1])
                        .frame(width: 20)
                }
            }
            Divider()
            HStack(spacing: 20) {
                AvatarView(user: game.player2).frame(width: 30)
                ForEach(results, id: \.self) { set in
                    Text("\(set[1])").bold(set[1] > set[0])
                        .frame(width: 20)
                }
            }
            Divider()
        }
    }
}

#Preview {
    NavigationStack {
        GameSummaryView(game: Game.fake())
    }
}
