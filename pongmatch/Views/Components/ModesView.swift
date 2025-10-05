import SwiftUI

struct ModesView: View {
    
    let initialScore: InitialScore
    let rankingType: RankingType
    let winningCondition: WinningCondition
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: InitialScore.icon)
                Text(initialScore.description)
            }.frame(maxWidth: .infinity)
            
            VStack {
                Image(systemName: RankingType.icon)
                Text(rankingType.description)
            }.frame(maxWidth: .infinity)
            
            VStack {
                Image(systemName: WinningCondition.icon)
                Text(winningCondition.description)
            }.frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    ModesView(
        initialScore: .fair,
        rankingType: .competitive,
        winningCondition: .bestof3
    )
}
