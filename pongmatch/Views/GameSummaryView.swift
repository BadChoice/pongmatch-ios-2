import SwiftUI

struct GameSummaryView : View {
    @State var game:Game
    
    @EnvironmentObject private var auth: AuthViewModel
    @Namespace private var namespace
    
    @State private var acceptChallenge = ApiAction()
    @State private var fetchPublicScoreboardCode = ApiAction()
    @State private var showUploadResultsSheet = false
    @State private var publicScoreboardCode: String? = nil
    
    var body: some View {
        ScrollView {
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
                        Label(game.ranking_type.description, systemImage: RankingType.icon)
                        Spacer()
                        Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                        
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
                    
                    FinalResult(game.finalResult)
                    
                    NavigationLink {
                        FriendView(user: game.player2)
                            .navigationTransition(.zoom(sourceID: "zoom_user_\(game.player2.id)", in: namespace))
                    } label: {
                        CompactUserView(user: game.player2, winner:game.winner()?.id == game.player2.id)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .matchedTransitionSource(id: "zoom_user_\(game.player2.id)", in: namespace)
                    }
                }
                .foregroundStyle(.primary)
                .padding(.vertical, 14)
                
                Divider()
                
                if let description = game.information {
                    Text(description)
                        .lineLimit(2, reservesSpace: true)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                    
                    Divider().padding(.bottom)
                }
                
                if game.isFinished() {
                    VStack(alignment: .leading) {
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
                
                
                VStack(spacing: 18) {
                    if game.status == .planned {
                        HStack {
                            NavigationLink {
                                ScoreboardView(score: Score(game: game))
                            } label: {
                                Label("Scoreboard", systemImage: "square.split.2x1")
                            }
                            .padding()
                            .foregroundStyle(.white)
                            .bold()
                            .glassEffect(.regular.tint(Color.accentColor).interactive())
                        }
                        
                    }
                    if game.status == .waitingOpponent && game.player2.id == auth.user.id {
                        VStack(alignment: .center) {
                            Text("YOU HAVE BEEN CHALLENGED")
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                        }
                        
                        Spacer()
                    }
                    
                    publicScoreboardCodeView
                    
                }
                Spacer()
            }
        }
        .toolbar {
            if game.status == .planned {
                ToolbarItem(placement: .bottomBar) {
                    Button{
                        showUploadResultsSheet = true
                    } label :{
                        Label("Upload results", systemImage: "arrow.up.circle.fill")
                    }
                }
            }
            
            if game.status == .planned && publicScoreboardCode == nil {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        getPublicScoreboardCode()
                    } label: {
                        Label("Public Code", systemImage: "lock.circle.dotted")
                    }
                }
            }
            
            if game.status == .planned {
                ToolbarItem(placement: .bottomBar) {
                    Label("Add to calendar", systemImage: "calendar.badge.plus")
                }
                    
            }
            
            if game.status == .waitingOpponent && game.player2.id == auth.user.id {
                ToolbarItem(placement: .primaryAction){
                    Button {
                        Task { await acceptChallenge.run {
                            game = try await auth.api.acceptChallenge(game)
                        } }
                    }
                    label: {
                        HStack {
                            if acceptChallenge.loading { ProgressView() }
                            Label("Accept Challenge", systemImage: "checkmark")
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar){
                    Button {
                        Task { await acceptChallenge.run {
                            game = try await auth.api.declineChallenge(game)
                        }}
                    }
                    label: {
                        HStack {
                            if acceptChallenge.loading { ProgressView() }
                            Label("Decline Challenge", systemImage: "xmark")
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            
                ToolbarItem(placement: .bottomBar){
                    Menu {
                        if game.status == .waitingOpponent {
                            Button("Edit game", systemImage: "pencil") {
                                
                            }
                            
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                
                            }
                        }
                        
                        if game.status == .finished {
                            Button("Dispute result", systemImage: "flat") {
                                
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            
        }
        .sheet(isPresented: $showUploadResultsSheet) {
            UploadResultsView(game: game)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private var publicScoreboardCodeView: some View {
        if fetchPublicScoreboardCode.loading {
            Divider().padding(.vertical)
            ProgressView()
            Divider().padding(.vertical)
        }
        
        if let error = fetchPublicScoreboardCode.errorMessage {
            Divider().padding(.vertical)
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
            
            Divider().padding(.vertical)
        }
        
        if let publicScoreboardCode {
            Divider().padding(.vertical)
            HStack(spacing: 14){
                Text("\(publicScoreboardCode.prefix(3))")
                Text("\(publicScoreboardCode.suffix(3))")
            }
            .font(.largeTitle.bold())
            .tracking(2)
            
            Divider().padding(.vertical)
        }
    }
    
    private func getPublicScoreboardCode() {
        Task {
            await fetchPublicScoreboardCode.run {
                let code = try? await auth.api.getPublicScoreboardCode(game)
                await MainActor.run {
                    withAnimation { publicScoreboardCode = code }
                }
            }
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


#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return NavigationStack {
        GameSummaryView(game: Game.fake(
            status:.finished,
            player1: User.unknown(),
            player2: auth.user
        ))
    }.environmentObject(auth)
}
