import SwiftUI

struct TournamentsView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    @StateObject private var fetchingTournaments = ApiAction()
    @State var tournaments: [Tournament] = []
    @Namespace private var namespace
    
    var body: some View {
        List {
            if let errorMessage = fetchingTournaments.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            ForEach(tournaments, id:\.id) { tournament in
                Section {
                    NavigationLink {
                        TournamentView(tournament: tournament)
                            .navigationTransition(.zoom(sourceID: "zoom_tournament_\(tournament.id)", in: namespace))
                            
                    } label: {
                        TournamentRow(tournament:tournament)
                        .matchedTransitionSource(id: "zoom_tournament_\(tournament.id)", in: namespace)
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
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

struct TournamentRow : View {
    let tournament:Tournament
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading){
                
                if let url = tournament.photoUrl {
                    AsyncImage(url: url) { image in
                        image.image?.resizable()
                            .scaledToFill()
                        
                    }
                    .frame(height: 140)
                }
                
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
            
            entranceRanking
            
            if let maxPlayers = tournament.entry_max_players_slots {
                HStack {
                    Image(systemName: "person.3.fill")
                    Text("Max Slots:")
                    Text("\(maxPlayers)")
                        .bold()
                        .foregroundStyle(.primary)
                }
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
                            
            
            if let location = tournament.location {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(location.name)
                }
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
            
            Divider().padding(.top, 12)
            
            ModesView(
                initialScore: tournament.initial_score,
                rankingType: tournament.ranking_type,
                winningCondition: tournament.winning_condition,
            )
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .font(.footnote)
            .foregroundStyle(.secondary)
            
            Divider()
            
            Text("\(tournament.players_count) players")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
    }
    
    private var entranceRanking: some View {
        
        HStack {
            Image(systemName: "circle.fill")
            
            if tournament.entry_min_elo == nil && tournament.entry_max_elo == nil {
                Text("All levels")
            }
            else if tournament.entry_min_elo == nil && tournament.entry_max_elo != nil {
                Text("Max ELO:")
                Text("\(tournament.entry_max_elo!)")
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .bold()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
            else if tournament.entry_min_elo != nil && tournament.entry_max_elo == nil {
                Text("Min ELO:")
                Text("\(tournament.entry_min_elo!)")
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .bold()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
            else {
                Text("ELO between")
                Text("\(tournament.entry_min_elo!)")
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .bold()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                
                Text("-")
                Text("\(tournament.entry_max_elo!)")
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .bold()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .foregroundStyle(.secondary)
        .font(.footnote)
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        TournamentsView()
    }.environmentObject(auth)
}
