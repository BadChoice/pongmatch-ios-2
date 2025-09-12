import SwiftUI

struct UserHeaderView : View {
    let user:User
    
    var body: some View {
        VStack {
            UserView(user: user)
            VStack(spacing:8) {
                if let lastPlayed = user.last_match_date {
                    Text("Last played \(lastPlayed.displayForHumans)")
                        .font(.caption2)
                        .padding(.vertical, 2)
                        .foregroundStyle(.secondary)
                }
                
                HStack{
                    Text("WON").frame(width:80)
                    Text("ELO").frame(width:80)
                    Text("RANK").frame(width:80)
                    Text("LOST").frame(width:80)
                }
                .foregroundStyle(.gray)
                .padding(.top, 2)
                HStack{
                    Text("\(user.games_won ?? 0)").frame(width:80)
                    Text("\(user.ranking)").frame(width:80)
                    if let globalRanking = user.global_ranking {
                        Text("\(globalRanking)").frame(width:80)
                    } else {
                        Text("-").frame(width:80)
                    }
                    Text("\(user.games_lost ?? 0)").frame(width:80)
                }.bold()
            }
        }
    }
}

#Preview {
    UserHeaderView(user: User.me())
}
