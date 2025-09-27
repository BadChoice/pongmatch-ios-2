import SwiftUI

struct UserHeaderView : View {
    let user:User
    let globalRanking: Int?
    let showDetails:Bool
    
    init(user: User, showDetails:Bool = true, globalRanking: Int? = nil) {
        self.user = user
        self.globalRanking = globalRanking
        self.showDetails = showDetails
    }
    
    var body: some View {
        VStack {
            UserView(user: user)
            VStack(spacing:8) {
                
                if let lastPlayed = user.last_match_date {
                    HStack(spacing: 2){
                        Text("Last played ")
                        Text("\(lastPlayed.displayForHumans)").bold()
                    }
                    .font(.caption)
                    .padding(.top, 6)
                    .foregroundStyle(.secondary)
                }
                
                if showDetails {
                    
                    if let address = user.address {
                        HStack(spacing: 2) {
                            Label(address, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    
                    if let deepDetails = user.deepDetails {
                        HStack(spacing: 2) {
                            Text("\(deepDetails.followers)").bold()
                            Text("followers")
                            Text(" · ")
                            Text("\(deepDetails.following)").bold()
                            Text("following")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    if let acceptChallengesFrom = user.accept_challenge_requests_from {
                        HStack(spacing: 2) {
                            Text("Accept challenges from:")
                            Text("\(acceptChallengesFrom.description)").bold()
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                
                HStack{
                    Text("WON").frame(width:80)
                    Text("ELO").frame(width:80)
                    Text("RANK").frame(width:80)
                    Text("LOST").frame(width:80)
                }
                .foregroundStyle(.gray)
                .padding(.top, 12)
                
                
                
                HStack{
                    Text("\(user.games_won ?? 0)").frame(width:80)
                    Text("\(user.ranking)").frame(width:80)
                    if let globalRanking = user.deepDetails?.global_ranking ?? globalRanking {
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
