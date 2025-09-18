import SwiftUI

struct GameTypeSelectionView : View {
    
    @Binding var initialScore:InitialScore
    @Binding var winCondition:WinningCondition
    @Binding var rankingType:RankingType
    
    var body: some View {
        VStack {
            HStack {
                Label(InitialScore.title, systemImage: InitialScore.icon)
                Spacer()
                Picker("Initial score", selection: $initialScore) {
                    ForEach(InitialScore.allCases, id:\.self) { initialScore in
                        Text(initialScore.description)
                    }
                }
            }
            HStack{
                Label(WinningCondition.title, systemImage: WinningCondition.icon)
                Spacer()
                Picker("Win condition", selection: $winCondition) {
                    ForEach(WinningCondition.allCases, id:\.self) { condition in
                        Text(condition.description)
                    }
                }
            }
            HStack{
                Label(RankingType.title, systemImage: RankingType.icon)
                Spacer()
                Picker("Ranking Type", selection: $rankingType) {
                    ForEach(RankingType.allCases, id:\.self) { rankingType in
                        Text(rankingType.description)
                    }
                }
            }
        }
    }
}
