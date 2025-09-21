import SwiftUI
import Charts

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

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    return EloHistory(user: User.me())
        .environmentObject(auth)
}
