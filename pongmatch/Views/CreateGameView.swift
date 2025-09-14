import SwiftUI

struct CreateGameView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectingOpponent = false
    @State private var creatingGame = false
    @State private var opponent:User = User.unknown()
    @State private var errorMessage:String? = nil
    
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
                        Text("Today, 18:30")
                    }
                    HStack {
                        Label("Place", systemImage: "mappin.and.ellipse")
                        Spacer()
                        Text("My house")
                    }
                    HStack {
                        Label("Information", systemImage: "info.circle")
                        Spacer()
                        Text("None defined")
                    }
                }
                
                Divider().padding(.vertical)
                
                VStack(spacing: 10){
                    HStack {
                        Label("Intital Score", systemImage: "bird.fill")
                        Spacer()
                        Text("Standard")
                    }
                    HStack {
                        Label("Ranking type", systemImage: "chart.bar.fill")
                        Spacer()
                        Text("Friendly")
                    }
                    HStack {
                        Label("Winning condition", systemImage: "medal.fill")
                        Spacer()
                        Text("Best of 5")
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
                            ProgressView()
                        }
                        Label("Create", systemImage: "plus")
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
        
        let game = Game(ranking_type: .competitive, winning_condition: .bestof3, status: .waitingOpponent, player1: User.me(), player2: opponent)
        dismiss()
        
        do {
            let _ = try await auth.api.store(game: game)
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
