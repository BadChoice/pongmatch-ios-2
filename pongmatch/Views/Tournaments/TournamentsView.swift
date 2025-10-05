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
                Section {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading){
                            HStack {
                                Text(tournament.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Label(tournament.status.description, systemImage: tournament.status.icon)
                                    .font(.caption)
                            }
                            
                            if let info = tournament.information {
                                Text(info)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                        }
                        
                        
                        Divider().padding(.vertical)
                        
                        HStack {
                            if let organizer = tournament.user {
                                HStack {
                                    AvatarView(user: organizer)
                                        .frame(width:20, height:20)
                                    Text(organizer.name)
                                }
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                            }
                            
                            Spacer()
                            
                            if let date = tournament.date?.displayForHumans {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(date)
                                }
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                            }
                        }
                        
                        if let location = tournament.location {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(location.name)
                            }
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                        }
                        
                        Divider().padding(.vertical)
                        
                        ModesView(
                            initialScore: tournament.initial_score,
                            rankingType: tournament.ranking_type,
                            winningCondition: tournament.winning_condition,
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 14)
                    }
                }
            }
        }
        .task {
            let _ = await fetchingTournaments.run {
                tournaments = try await auth.api.tournaments.index()
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    //TODO
                } label: {
                    Image(systemName: "plus")
                }
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
