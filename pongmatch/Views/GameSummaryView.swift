import SwiftUI

struct GameSummaryView : View {
    let game:Game
    
    @EnvironmentObject private var auth: AuthViewModel
    @Namespace private var namespace
    
    @State private var acceptingChallenge = false
    @State private var showUploadResultsSheet = false
    
    var body: some View {
        VStack {
                 
            VStack(spacing: 10) {
                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: "calendar")
                        Text(game.date.displayForHumans)
                        Spacer()
                        Label(game.status.description, systemImage: game.status.icon)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                                
                HStack() {
                    /* Label("Standard", systemImage:"bird.fill") */
                    Label(game.ranking_type.description, systemImage: "trophy.fill")
                    Spacer()
                    Label(game.winning_condition.description, systemImage: "medal.fill")
                    
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                NavigationLink {
                    FriendView(user: game.player1)
                        .navigationTransition(.zoom(sourceID: "zoom_user_\(game.player1.id)", in: namespace))
                } label: {
                    CompactUserView(user: game.player1, winner:game.winner()?.id == game.player1.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .matchedTransitionSource(id: "zoom_user_\(game.player1.id)", in: namespace)
                }
                Group {
                    if let finalResult = game.finalResult{
                        HStack {
                            Text("\(finalResult[0]) - \(finalResult[1])")
                        }
                    }else{
                        Text("VS")
                    }
                }
                .font(.largeTitle.bold())
                
                NavigationLink {
                    FriendView(user: game.player2)
                        .navigationTransition(.zoom(sourceID: "zoom_user_\(game.player2.id)", in: namespace))
                } label: {
                    CompactUserView(user: game.player2, winner:game.winner()?.id == game.player2.id)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .matchedTransitionSource(id: "zoom_user_\(game.player2.id)", in: namespace)
                }
            }
            .foregroundStyle(.black)
            .padding(.vertical, 20)
            
            
            
            if game.isFinished() {
                Divider()
                VStack(alignment: .leading) {
                    Text("Sets").font(.title2)
                    SetsScoreView2(game:game)
                }
                .padding()
            }
            
            // https://ttcup.com/videos/4558453588f55d5aa02ddf8dd46deefc66f086f3/
            // Winning percentage per own server per set
            // Set time
            // Match time
            // Points percentage per set and overall
            // Max consecutive points strike per set and overall
            // Set history table
            
            Divider().padding(.bottom)
            
            VStack(spacing: 18) {
                if game.status == .planned {
                    NavigationLink {
                        ScoreboardView(score: Score(game: game))
                    } label: {
                        Label("Scoreboard", systemImage: "square.split.2x1")
                    }
                    .padding()
                    .glassEffect()
                    
                    Label("Upload results", systemImage: "arrow.up.circle.fill")
                        .padding()
                        .glassEffect()
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            showUploadResultsSheet = true
                        }
                }
                
                GlassEffectContainer{
                    HStack {
                        if game.status == .waitingOpponent && game.player2.id == auth.user.id {
                            Button {
                                Task {
                                    try await auth.api.acceptChallenge(game)
                                }
                            } label: {
                                HStack{
                                    if acceptingChallenge { ProgressView() }
                                    Label("Accept", systemImage: "checkmark")
                                }
                                .padding()
                                
                            }
                            .bold()
                            .glassEffect()
                            .glassEffectUnion(id: "1", namespace: namespace)
                            .disabled(acceptingChallenge)
                            
                            
                            Button {
                                Task {
                                    try await auth.api.declineChallenge(game)
                                }
                            } label: {
                                HStack{
                                    if acceptingChallenge { ProgressView() }
                                    Label("Decline", systemImage: "xmark" )
                                }
                                .padding()
                            }
                            .foregroundStyle(.red)
                            .glassEffect()
                            .glassEffectUnion(id: "1", namespace: namespace)
                            .disabled(acceptingChallenge)
                        }
                    }
                }
                
                if game.isFinished() {
                    Button("Share", systemImage: "square.and.arrow.up") { }
                        .padding()
                        .glassEffect()
                } else {
                    Button("Add to calendar", systemImage: "calendar.badge.plus") { }
                        .padding()
                        .glassEffect()
                }
                
            }
            Spacer()
        }
        .sheet(isPresented: $showUploadResultsSheet) {
            UploadResultsView(game: game)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct SetsScoreView2: View {
    let game:Game
    
    var results:[[Int]] {
        game.results ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 20) {
                AvatarView(user: game.player1).frame(width: 30)
                ForEach(results, id: \.self) { set in
                    Text("\(set[0])").bold(set[0] > set[1])
                        .frame(width: 20)
                }
            }
            Divider()
            HStack(spacing: 20) {
                AvatarView(user: game.player2).frame(width: 30)
                ForEach(results, id: \.self) { set in
                    Text("\(set[1])").bold(set[1] > set[0])
                        .frame(width: 20)
                }
            }
            Divider()
        }
    }
}



#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return NavigationStack {
        GameSummaryView(game: Game.fake())
    }.environmentObject(auth)
}


#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return NavigationStack {
        GameSummaryView(game: Game.fake(
            status:.waitingOpponent,
            player1: User.unknown(),
            player2: auth.user
        ))
    }.environmentObject(auth)
}
