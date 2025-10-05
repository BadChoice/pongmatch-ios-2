import SwiftUI

struct TournamentsView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    @StateObject private var fetchingTournaments = ApiAction()
    @State var tournaments: [Tournament] = []
    
    var body: some View {
        List {
            if let errorMessage = fetchingTournaments.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            ForEach(tournaments, id:\.id) { tournament in
                Text(tournament.name)
            }
        }
        .task {
            let _ = await fetchingTournaments.run {
                tournaments = try await auth.api.tournaments.index()
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        TournamentsView()
    }.environmentObject(auth)
}
