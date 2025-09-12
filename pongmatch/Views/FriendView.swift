import SwiftUI
import Charts


struct FriendView : View {
    let user:User
    @State private var selectedSegment = 0

    
    var body: some View {
        VStack(spacing:24){
            UserHeaderView(user: user)
            
            Divider()
            HStack(spacing:40) {
                Button("Challenge") { }
                Button("Follow") { }
            }
            
            Divider()
            
            VStack(alignment: .leading){
                Text("ELO Evolution")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                EloHistory(user:user)
                    .frame(height: 120)
                    .padding()
            }
            
            Picker("Match Type", selection: $selectedSegment) {
                Text("Upcoming").tag(0)
                Text("Recent").tag(1)
                Text("1 VS 1").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Group {
                switch selectedSegment {
                case 0:
                    Text("Next matches for \(user.name)")
                case 1:
                    Text("Previous matches for \(user.name)")
                case 2:
                    Text("1vs1 matches for \(user.name)")
                default:
                    EmptyView()
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

struct EloHistory : View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var selectedEntry: EloEntry?

    
    let user:User
    
    struct EloEntry: Identifiable {
        let id = UUID()
        let date: Date
        let elo: Int
    }
    
    // Placeholder ELO history
    @State var eloHistory: [EloEntry]? = [
        EloEntry(date: .now.addingTimeInterval(-86400 * 5), elo: 1500),
        EloEntry(date: .now.addingTimeInterval(-86400 * 4), elo: 1430),
        EloEntry(date: .now.addingTimeInterval(-86400 * 3), elo: 1480),
        EloEntry(date: .now.addingTimeInterval(-86400 * 2), elo: 1502),
        EloEntry(date: .now.addingTimeInterval(-86400), elo: 1560),
        EloEntry(date: .now, elo: 1610)
    ]
    
    var body: some View {
        Group{
            if let eloHistory = eloHistory, !eloHistory.isEmpty {
                Chart {
                    ForEach(eloHistory) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("ELO", entry.elo)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue)
                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("ELO", entry.elo)
                        )
                        .foregroundStyle(Color.blue.opacity(0.7))
                        .accessibilityLabel("\(entry.elo)")
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis(.hidden)
            } else {
                Text("No ELO history available")
            }
        }
        .task {
            Task {
                eloHistory = (try await auth.api.eloHistory(user).map {
                    EloEntry(date: $0.date, elo: $0.elo)
                })
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return FriendView(user: User.me())
        .environmentObject(auth)
}
