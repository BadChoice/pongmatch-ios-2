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
                        searchingPlayer2 = true
                    } label: {
                        UserView(user: player2)
                            .foregroundStyle(.black)
                    }.padding(.trailing)
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
        }
        .padding()
        .sheet(isPresented: $searchingPlayer2) {
            SearchOpponentView(selectedFriend: $player2) { selected in
                player2 = selected
                searchingPlayer2 = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    return ScoreboardSelectionView { player2, winningCondition, rankingType in }.environmentObject(auth)
}
