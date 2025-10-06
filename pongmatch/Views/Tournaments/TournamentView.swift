import SwiftUI

struct TournamentView : View {
    let tournament:Tournament
    
    var body: some View {
        Text("Tournament View")
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        TournamentView(tournament: auth.api!.tournaments.index().first!)
    }
    .environmentObject(auth)
}
