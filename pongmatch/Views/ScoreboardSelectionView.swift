import SwiftUI

struct ScoreboardSelectionView : View {
    
    var onSelect: (User, WinningCondition, RankingType) -> Void

    @State private var winCondition:WinningCondition = .bestof3
    @State private var rankingType:RankingType = .friendly
    @State private var player2:User = User.unknown()
    
    @State private var searchingPlayer2 = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Scoreboard")
                .padding(.top)
                .font(.largeTitle)
            
            
            HStack{
                Text("Win condition").bold()
                Spacer()
                Picker("Win condition", selection: $winCondition) {
                    ForEach(WinningCondition.allCases, id:\.self) { condition in
                        Text(condition.rawValue.capitalized)
                    }
                }
            }
            HStack{
                Text("Ranking Type").bold()
                Spacer()
                Picker("Ranking Type", selection: $rankingType) {
                    ForEach(RankingType.allCases, id:\.self) { rankingType in
                        Text(rankingType.rawValue.capitalized)
                    }
                }
            }
            if !searchingPlayer2 {
                HStack{
                    Text("Play against").bold()
                    Spacer()
                    Button {
                        withAnimation { searchingPlayer2.toggle() }
                    } label: {
                        UserView(user: player2)
                    }.padding(.trailing)
                }
            } else {
                SearchFriendView(selectedFriend: $player2) { player2 in
                    withAnimation {
                        self.player2 = player2
                        searchingPlayer2.toggle()
                    }
                }
            }
            
            Spacer()
            Button {
                onSelect(player2, winCondition, rankingType)
            } label:{
                Label("START", systemImage: "circle.fill")
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.black)
                    .clipShape(.capsule)
                    .foregroundStyle(.white)
            }

            
        }.padding()
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    return ScoreboardSelectionView { player2, winningCondition, rankingType in }.environmentObject(auth)
}
