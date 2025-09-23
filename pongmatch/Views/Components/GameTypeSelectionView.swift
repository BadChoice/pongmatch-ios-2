import SwiftUI

struct GameTypeSelectionView : View {
    
    @Binding var initialScore:InitialScore
    @Binding var winCondition:WinningCondition
    @Binding var rankingType:RankingType
    
    @State private var showInitialScoreHelp = false
    @State private var showWinningConditionHelp = false
    @State private var showRankingTypeHelp = false
    
    var body: some View {
        VStack {
            HStack {
                Label(InitialScore.title, systemImage: InitialScore.icon)
                Button {
                    showInitialScoreHelp = true
                } label: {
                    Image(systemName: "info.circle")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Initial Score info")
                }
                .help(initialScore.help)
                
                Spacer()
                Picker("Initial score", selection: $initialScore) {
                    ForEach(InitialScore.allCases, id:\.self) { initialScore in
                        Text(initialScore.description)
                            .tag(initialScore)
                    }
                }
            }
            .alert("Initial Score", isPresented: $showInitialScoreHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(initialScore.help)
            }
            
            HStack{
                Label(WinningCondition.title, systemImage: WinningCondition.icon)
                Button {
                    showWinningConditionHelp = true
                } label: {
                    Image(systemName: "info.circle")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Winning Condition info")
                }
                .help(winCondition.help)
                
                Spacer()
                Picker("Win condition", selection: $winCondition) {
                    ForEach(WinningCondition.allCases, id:\.self) { condition in
                        Text(condition.description)
                            .tag(condition)
                    }
                }
            }
            .alert("Winning Condition", isPresented: $showWinningConditionHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(winCondition.help)
            }
            
            HStack{
                Label(RankingType.title, systemImage: RankingType.icon)
                Button {
                    showRankingTypeHelp = true
                } label: {
                    Image(systemName: "info.circle")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Ranking Type info")
                }
                .help(rankingType.help)
                
                Spacer()
                Picker("Ranking Type", selection: $rankingType) {
                    ForEach(RankingType.allCases, id:\.self) { rankingType in
                        Text(rankingType.description)
                            .tag(rankingType)
                    }
                }
            }
            .alert("Ranking Type", isPresented: $showRankingTypeHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(rankingType.help)
            }
        }
    }
}
