import SwiftUI

struct ScoreboardSelectionView : View {
    
    @State private var rankingType:RankingType = .friendly
    @State private var winningCondition:WinningCondition = .bestof3
    
    var body: some View {
        
        Picker("Ranking Type", selection: $rankingType) {
            ForEach(RankingType.allCases, id:\.self) { rankingType in
                Text(rankingType.rawValue.capitalized)
            }
        }
        
        Picker("Win condition", selection: $winningCondition) {
            ForEach(WinningCondition.allCases, id:\.self) { condition in
                Text(condition.rawValue.capitalized)
            }
        }
        
        NavigationLink("Start") {
            ScoreboardView(score: Score(game:
                Game(
                    id: -1,
                    ranking_type: rankingType,
                    winning_condition: winningCondition,
                    information: nil,
                    date: Date(),
                    status: .ongoing,
                    player1: IPhoneSync.authUser() ?? User.unknown(),
                    player2: User.unknown()
                )
            ))
        }
    }
    
}

#Preview {
    ScoreboardSelectionView()
}
