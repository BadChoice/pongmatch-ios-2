import SwiftUI

struct TournamentView : View {
    let tournament:Tournament
    
    var body: some View {
        List {
            TournamentRow(tournament: tournament)
        }
        .navigationTitle(tournament.name)
        
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
