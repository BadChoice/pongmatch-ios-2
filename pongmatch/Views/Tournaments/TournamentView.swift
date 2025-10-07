import SwiftUI

struct TournamentView : View {
    @EnvironmentObject var auth:AuthViewModel
        
    @State var details:Api.Tournaments.TournamentDetails?
    @StateObject var fetchingDetails = ApiAction()
    let tournament:Tournament
    
    var body: some View {
        List {
            TournamentRow(tournament: tournament)
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(details?.players ?? [], id:\.id){
                            AvatarView(user: $0)
                                .frame(width:40, height:40)
                        }
                    }
                }
            }
            Section {
                GamesScrollView(games: details?.games ?? [])
            }
        }
        .navigationTitle(tournament.name)
        .task {
            let _ = await fetchingDetails.run {
                details = try await auth.api.tournaments.get(id: tournament.id)
            }
        }
        
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        TournamentView(tournament: Tournament.fake())
    }
    .environmentObject(auth)
}
