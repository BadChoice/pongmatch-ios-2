import SwiftUI

struct CreateGameView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectingOpponent = false
    @State private var creatingGame = false
    @State private var opponent:User
    @State private var errorMessage:String? = nil
    @State private var selectedDate = Date()
    @State private var initialScore: InitialScore = .standard
    @State private var rankingType: RankingType = .friendly
    @State private var winningCondition: WinningCondition = .bestof5
    
    init(opponent:User? = nil) {
        self.opponent = opponent ?? User.unknown()
    }
    
    var body: some View {
        ScrollView{
            VStack {
                HStack{
                    CompactUserView(user: auth.user)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    Text("VS").font(.largeTitle.bold())
                                        
                    Group {
                        if opponent.isUnknown {
                            Image(systemName: "plus.circle.dashed")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .fontWeight(.light)
                                .foregroundStyle(.blue)
                                
                        } else {
                            CompactUserView(user: opponent)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .onTapGesture {
                        selectingOpponent = true
                    }
                    
                }
                
                Divider().padding(.vertical)
                VStack(spacing: 10){
                    HStack {
                        Label("Date", systemImage: "calendar")
                        Spacer()
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                    
                    GameTypeSelectionView(
                        initialScore: $initialScore,
                        winCondition: $winningCondition,
                        rankingType: $rankingType
                    )
                }
                
                Divider().padding(.vertical)
                
                Spacer()
                
                Button {
                    Task{
                        await createGame()
                    }
                } label:{
                    HStack{
                        if creatingGame {
                            ProgressView().tint(.white)
                        } else {
                            Label("Create", systemImage: "plus")
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth:.infinity)
                    .bold()
                    .background(opponent.isUnknown ? .gray.opacity(0.2) : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                }.disabled(creatingGame || opponent.isUnknown)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $selectingOpponent) {
            SearchOpponentView(selectedFriend: $opponent){
                opponent = $0
                selectingOpponent = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func createGame() async {
        guard !opponent.isUnknown else {
            return
        }
        creatingGame = true
        defer { creatingGame = false }
        
        do {
            let _ = try await auth.api.store(game: Game(
                initial_score: initialScore,
                ranking_type: rankingType,
                winning_condition: winningCondition,
                status: .waitingOpponent,
                player1: User.me(),
                player2: opponent
            ))
            dismiss()
            try? await auth.loadGames()
        } catch {
            errorMessage = "\(error)"
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return CreateGameView().environmentObject(auth)
}
