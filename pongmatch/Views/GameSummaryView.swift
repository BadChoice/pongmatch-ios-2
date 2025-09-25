import SwiftUI
internal import RevoFoundation

struct GameSummaryView : View {
    @State var game:Game
    
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Namespace private var namespace
        
    @State private var acceptChallenge = ApiAction()
    @State private var fetchPublicScoreboardCode = ApiAction()
    @State private var fetchPlayersDetails = ApiAction()
    @State private var uploadWatchResults = ApiAction()
    
    @State private var showUploadResultsSheet = false
    @State private var publicScoreboardCode: String? = nil
    
    @State private var deleteGame = ApiAction()
    
    @StateObject private var calendarManager = CalendarManager()
    
    @State private var player1Details:Api.PlayerDetails? = nil
    @State private var player2Details:Api.PlayerDetails? = nil
    
    @State private var showScoreboard = false

    
    var body: some View {
        ScrollView {
            VStack {
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
                .overlay(alignment:.top) {
                    Label(game.status.description, systemImage: game.status.icon)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                        .font(.subheadline.bold())
                        .offset(x:0, y:-12)
                }
                .overlay(alignment:.bottom) {
                    Label(game.date.displayForHumans, systemImage: "calendar")
                        .font(Font.caption.bold())
                        .foregroundStyle(.secondary)
                        .offset(x:0, y:-10)
                }
                
                Divider()
                
                VStack(spacing: 10) {
                    HStack {
                                                
                        /* Label("Standard", systemImage:"bird.fill") */
                        Label(game.ranking_type.description, systemImage: RankingType.icon)
                        Spacer()
                        Label(game.winning_condition.description, systemImage: WinningCondition.icon)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                
                Divider()
                
                if let description = game.information {
                    Text(description)
                        .lineLimit(2, reservesSpace: true)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    Divider()
                }
                
                earnedPoints
                
                if let results = game.results, !results.isEmpty {
                    WinLossBar(
                        me:game.player1,
                        friend: game.player2,
                        wins: results.sum { $0[0] },
                        losses: results.sum { $0[1] },
                        label: "Points ratio"
                    )
                    .padding()
                        
                    
                    VStack(alignment: .leading) {
                        HorizontalSetsScoreView(game:game)
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
                            Button {
                                showScoreboard.toggle()
                            } label: {
                                Label("Scoreboard", systemImage: "square.split.2x1")
                            }
                            .padding()
                            .foregroundStyle(.white)
                            .bold()
                            .glassEffect(.regular.tint(Color.accentColor).interactive())
                        }
                        .padding(.vertical)
                    }
                    
                    if game.status == .waitingOpponent && game.player2.id == auth.user.id {
                        VStack(alignment: .center) {
                            Text("YOU HAVE BEEN CHALLENGED!")
                                .multilineTextAlignment(.center)
                                .font(.largeTitle.bold())
                        }.padding(.top, 48)
                        
                        Spacer()
                    }
                    publicScoreboardCodeView
                }
                Spacer()
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing){
                Menu {
                    if game.status == .waitingOpponent {
                        Button("Edit game", systemImage: "pencil") {
                            
                        }
                        
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task {
                                if (await deleteGame.run {
                                    try await auth.api.delete(game: game)
                                }) {
                                    dismiss()
                                }
                            }
                        }.disabled(deleteGame.loading)
                    }
                    
                    if game.status == .finished {
                        Button("Dispute result", systemImage: "flag") {
                            
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            GlassEffectContainer {
                HStack {
                    if game.status == .planned {
                        Button{
                            showUploadResultsSheet = true
                        } label :{
                            Image(systemName: "icloud.and.arrow.up")
                                .frame(width: 20.0, height: 20.0)
                                .font(.system(size: 22))
                                .padding()
                                .glassEffect(.regular.interactive())
                                .glassEffectUnion(id: "1", namespace: namespace)
                        }

                    }
                    
                    if game.status == .planned && publicScoreboardCode == nil {
                        Button {
                            getPublicScoreboardCode()
                        } label: {
                            Image(systemName: "lock.circle.dotted")
                                .frame(width: 20.0, height: 20.0)
                                .font(.system(size: 22))
                                .padding()
                                .glassEffect(.regular.interactive())
                                .glassEffectUnion(id: "1", namespace: namespace)
                        }
                    }
                    
                    if game.status == .planned && game.date > Date() {
                        Button {
                            calendarManager.requestAccess { granted in
                                guard granted else {
                                    return
                                }
                                try? calendarManager.addEvent(
                                    title: "Ping Pong Match",
                                    startDate: game.date,
                                    endDate: game.date.addingTimeInterval(900) // 15 min
                                )
                            }
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                                .frame(width: 20.0, height: 20.0)
                                .font(.system(size: 22))
                                .padding()
                                .glassEffect(.regular.interactive())
                                .glassEffectUnion(id: "1", namespace: namespace)
                        }
                    }
                    
                    if game.status == .finished && game.needsId{
                        Button {
                            WatchFinishedGames.shared.remove(game: game)
                            dismiss()
                        }
                        label: {
                            Image(systemName: "trash")
                        }
                        .padding()
                        .glassEffect(.regular.interactive())
                        
                        if !game.hasAnUnknownPlayer() {
                            Button {
                                Task {
                                    let didUpload = await uploadWatchResults.run {
                                        let newGame = try await auth.api.store(game: game)
                                        let _ = try await auth.api.uploadResults(newGame, results:game.results)
                                        WatchFinishedGames.shared.remove(game: game)
                                    }
                                    if didUpload {
                                        dismiss()
                                    }
                                }
                            }
                            label: {
                                HStack {
                                    if uploadWatchResults.loading { ProgressView() }
                                    else { Image(systemName: "icloud.and.arrow.up.fill") }
                                }
                            }
                            .padding()
                            .buttonStyle(.glassProminent)
                            .glassEffect(.regular.tint(.primary).interactive())
                        }
                    }
                    
                    if game.status == .waitingOpponent && game.player2.id == auth.user.id {
                        Button {
                            Task { await acceptChallenge.run {
                                game = try await auth.api.declineChallenge(game)
                                dismiss()
                            }}
                        }
                        label: {
                            HStack {
                                if acceptChallenge.loading { ProgressView() }
                                else { Image(systemName: "xmark") }
                            }
                        }
                        .foregroundStyle(.red)
                        .padding()
                        .glassEffect(.regular.interactive())
                        
                        
                        Button {
                            Task { await acceptChallenge.run {
                                game = try await auth.api.acceptChallenge(game)
                                dismiss()
                            }}
                        }
                        label: {
                            HStack {
                                if acceptChallenge.loading { ProgressView() }
                                else { Image(systemName: "checkmark") }
                            }
                        }
                        .bold()
                        .padding()
                        .buttonStyle(.glassProminent)
                        .glassEffect(.regular.tint(.primary).interactive())
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .task {
            if game.isFinished() && game.ranking_type == .competitive {
                Task {
                    (player1Details, player2Details) = try await auth.api.playersDetails(game: game)
                }
            }
        }
        .fullScreenCover(isPresented: $showScoreboard) {
            ScoreboardView(score: Score(game: game))
        }
        .sheet(isPresented: $showUploadResultsSheet) {
            Task {
                try? await auth.loadGames()
                dismiss()
            }
        }
        content: {
            UploadResultsView(game: $game)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private var earnedPoints: some View {
        
        if let player1Details, let player2Details {
            VStack{
                HStack {
                    
                    Image(systemName: player1Details.earned_points ?? 0 > 0 ? "arrow.up" : "arrow.down")
                            .foregroundStyle(player1Details.earned_points ?? 0 > 0 ? .green : .red)
                    
                    Text("\(player1Details.earned_points ?? 0)")
                        .bold()
                    Text("\(player1Details.resulting_points ?? 0)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    
                    Spacer()
                    
                    Text("\(player2Details.earned_points ?? 0)")
                        .bold()
                    Text("\(player2Details.resulting_points ?? 0)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: player2Details.earned_points ?? 0 > 0 ? "arrow.up" : "arrow.down")
                            .foregroundStyle(player2Details.earned_points ?? 0 > 0 ? .green : .red)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                
                Divider()
            }
            .foregroundStyle(.primary)
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

struct HorizontalSetsScoreView: View {
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
