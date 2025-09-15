import SwiftUI

struct ScoreboardSelectionView : View {
    
    var onSelect: (Game) -> Void

    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var winCondition:WinningCondition = .bestof3
    @State private var rankingType:RankingType = .friendly
    @State private var player2:User = User.unknown()
    
    @State private var searchingPlayer2 = false
    
    @State private var publicScoreboardCode = ""

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
            

            Button {
                onSelect(
                    Game(
                        ranking_type: rankingType,
                        winning_condition: winCondition,
                        status: .ongoing,
                        player1: User.me(),
                        player2: player2
                    )
                )
            } label:{
                Label("START", systemImage: "play.fill")
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.black)
                    .clipShape(.capsule)
                    .foregroundStyle(.white)
            }
            Text("Start a match with the selected values")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Divider().padding(.vertical, 40)
            
            // MARK - One time code
            VStack(spacing: 10) {
                TextField("One time code", text: $publicScoreboardCode)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button {
                    searchGameWithScoreboardCode()
                } label:{
                    Label("START", systemImage: "lock.circle.dotted")
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(.black)
                        .clipShape(.capsule)
                        .foregroundStyle(.white)
                }
                
                Text("Enter the one time code to start it with the digital scoreboard")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
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
    
    private func searchGameWithScoreboardCode() {
        Task {
            if let game = try? await auth.api.getGame(publicScoreboardCode: publicScoreboardCode) {
                await MainActor.run {
                    onSelect(game)
                }
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    return ScoreboardSelectionView { game in }.environmentObject(auth)
}
