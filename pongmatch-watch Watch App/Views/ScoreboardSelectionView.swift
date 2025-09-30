import SwiftUI

struct ScoreboardSelectionView : View {
    
    @State private var initialScore:InitialScore = .standard
    @State private var rankingType:RankingType = .friendly
    @State private var winningCondition:WinningCondition = .bestof3
    
    var body: some View {
        ScrollView{
            VStack {
                HStack{
                    Picker("Initial Score", selection: $initialScore) {
                        ForEach(InitialScore.allCases, id:\.self) { initialScore in
                            Text(initialScore.rawValue.capitalized)
                        }
                    }
                    
                    Picker("Win condition", selection: $winningCondition) {
                        ForEach(WinningCondition.allCases, id:\.self) { condition in
                            Text(condition.rawValue.capitalized)
                        }
                    }
                }.frame(height:60)
                
                HStack{
                    Picker("Ranking Type", selection: $rankingType) {
                        ForEach(RankingType.allCases, id:\.self) { rankingType in
                            Text(rankingType.rawValue.capitalized)
                        }
                    }
                }.frame(height:60)
                
                NavigationLink("Start") {
                    ScoreboardView(score: Score(game:
                        Game(
                            id: -1,
                            initial_score: initialScore,
                            ranking_type: rankingType,
                            winning_condition: winningCondition,
                            information: nil,
                            date: Date(),
                            status: .ongoing,
                            player1: IPhoneSync.authUser() ?? User.unknown(),
                            player2: User.unknown()
                        )
                   ))
                }.padding(.vertical, 20)
            }
        }
    }
    
}

#Preview {
    ScoreboardSelectionView()
}
