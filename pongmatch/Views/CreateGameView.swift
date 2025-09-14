import SwiftUI

struct CreateGameView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectingOpponent = false
    @State private var creatingGame = false
    @State private var opponent:User = User.unknown()
    @State private var errorMessage:String? = nil
    @State private var selectedDate = Date()
    @State private var initialScore: InitialScore = .standard
    @State private var rankingType: RankingType = .friendly
    @State private var winningCondition: WinningCondition = .bestof5
    
    var body: some View {
        ScrollView{
            VStack {
                HStack{
                    UserView(user: User.me())
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    Text("VS").font(.largeTitle.bold())
                    
                    
                    Group {
                        if opponent.id == User.unknown().id {
                            Image(systemName: "plus.circle.dashed")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .fontWeight(.light)
                                .foregroundStyle(.blue)
                                
                        } else {
                            UserView(user: opponent)
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
                    HStack {
                        Label("Initial Score", systemImage: "bird.fill")
                        Spacer()
                        Picker("", selection: $initialScore) {
                            Text("Standard").tag(InitialScore.standard)
                            Text("Fair").tag(InitialScore.fair)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                    HStack {
                        Label("Ranking type", systemImage: "trophy.fill")
                        Spacer()
                        Picker("", selection: $rankingType) {
                            ForEach(RankingType.allCases, id: \ .self) { type in
                                Text(type.description).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                    HStack {
                        Label("Winning condition", systemImage: "medal.fill")
                        Spacer()
                        Picker("", selection: $winningCondition) {
                            ForEach(WinningCondition.allCases, id: \ .self) { condition in
                                switch condition {
                                case .single: Text("Single").tag(condition)
                                case .bestof3: Text("Best of 3").tag(condition)
                                case .bestof5: Text("Best of 5").tag(condition)
                                case .bestof7: Text("Best of 7").tag(condition)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                }
                
                Divider().padding(.vertical)
                
                
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
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                }.disabled(creatingGame || opponent.id == User.unknown().id)
                
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
        guard opponent.id != User.unknown().id else {
            return
        }
        creatingGame = true
        defer { creatingGame = false }
        
        do {
            let _ = try await auth.api.store(game: Game(
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
