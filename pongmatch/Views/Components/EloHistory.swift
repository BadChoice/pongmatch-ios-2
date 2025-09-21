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
                // Compute min/max with padding so axis doesn’t touch the line
                let minElo = eloHistory.map(\.elo).min() ?? 0
                let maxElo = eloHistory.map(\.elo).max() ?? 0
                let range = max(1, maxElo - minElo)
                
                // Increase padding to ~15% of range, with a minimum absolute padding
                let percentPad = max(0.15, 0.15) // explicit, easy to tweak
                let absoluteMinPad = 8           // minimum points of padding
                let computedPad = max(Double(absoluteMinPad), Double(range) * percentPad)
                
                let lower = Double(minElo) - computedPad
                let upper = Double(maxElo) + computedPad

                Chart {
                    ForEach(eloHistory.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Date", index),
                            y: .value("ELO", Double(eloHistory[index].elo))
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue)
                        PointMark(
                            x: .value("Date", index),
                            y: .value("ELO", Double(eloHistory[index].elo))
                        )
                        .foregroundStyle(Color.blue.opacity(0.7))
                        .accessibilityLabel("\(eloHistory[index].elo)")
                    }
                }
                .chartYScale(domain: lower...upper)
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
                eloHistory = try await auth.api.eloHistory(user).map {
                    EloEntry(date: $0.date, elo: $0.elo)
                }
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
