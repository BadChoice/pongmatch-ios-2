import SwiftUI
import Charts


struct FriendView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    let user:User
    
    @State private var selectedSegment = 0
    @State private var deepDetails:UserDeepDetails? = nil
    
    @State var isFollowed:Bool
    
    init(user:User) {
        self.user = user
        self.isFollowed = user.friendship?.isFollowed ?? false
    }
    
    var body: some View {
        VStack(spacing:24){
            UserHeaderView(user: user, globalRanking: deepDetails?.global_ranking)
            
            if let deepDetails {
                HStack{
                    Text("\(deepDetails.followers) followers")
                    Text(" · ")
                    Text("\(deepDetails.following) following")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            
            Divider()
            HStack(spacing:40) {
                Button("Challenge", systemImage: "figure.boxing") {
                    
                }.font(.caption)
                FollowButton(user: user, isFollowed: $isFollowed)
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
        }.task {
            Task {
                let deepDetails = try? await auth.api.deepDetails(user)
                withAnimation {
                    self.deepDetails = deepDetails
                }
            }
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
                    ForEach(eloHistory.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Date", index),
                            y: .value("ELO", eloHistory[index].elo)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue)
                        PointMark(
                            x: .value("Date", index),
                            y: .value("ELO", eloHistory[index].elo)
                        )
                        .foregroundStyle(Color.blue.opacity(0.7))
                        .accessibilityLabel("\(eloHistory[index].elo)")
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

struct FollowButton : View {
    @EnvironmentObject private var auth: AuthViewModel
    let user:User
    @Binding var isFollowed:Bool
    
    var body: some View {
        
        Button {
            Task {
                try await isFollowed ? auth.api.unfollow(user) : auth.api.follow(user)
                withAnimation { isFollowed.toggle()}
            }
        } label: {
            Label(isFollowed ? "Following" : "Follow",
                  systemImage: "heart.fill")
                
        }
        .font(.caption)
        .padding(6)
        .background(isFollowed ? Color.accentColor : .clear)
        .foregroundStyle(isFollowed ? .white : .blue)
        .cornerRadius(8)
    }

}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return FriendView(user: User.me())
        .environmentObject(auth)
}
