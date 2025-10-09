import SwiftUI

struct BracketsView: View {
    let games: [Game]
    
    // Group games by round number (ignore nil rounds)
    private var rounds: [(round: Int, games: [Game])] {
        let grouped = Dictionary(grouping: games.compactMap { $0.round != nil ? $0 : nil }) { $0.round ?? -1 }
        return grouped
            .map { (round: $0.key, games: $0.value.sorted { ($0.id) < ($1.id) }) }
            .sorted { $0.round < $1.round }
    }
    
    // State that holds measured centers per game id
    @State private var centersByGameID: [Int: CGPoint] = [:]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            GeometryReader { scrollGeo in
                let columnSpacing: CGFloat = 24
                HStack(alignment: .top, spacing: columnSpacing) {
                    ForEach(Array(rounds.enumerated()), id: \.1.round) { (roundIndex, roundTuple) in
                        let round = roundTuple.round
                        let gamesInRound = roundTuple.games
                        
                        // Compute offsets for this round using previous round centers.
                        // Round 0 has no previous round -> zero offsets.
                        let offsets = offsetsForRound(
                            roundIndex: roundIndex,
                            gamesInRound: gamesInRound,
                            rounds: rounds,
                            centersByGameID: centersByGameID
                        )
                        
                        RoundColumnView(round: round, games: gamesInRound, offsets: offsets)
                    }
                }
                .padding()
                // Collect anchors from all match cards
                .background(
                    BracketConnections(rounds: rounds, centersByGameID: centersByGameID)
                        .allowsHitTesting(false)
                )
            }
        }
        // We need to resolve anchors to points. We do that by using an overlay GeometryReader
        .overlayPreferenceValue(MatchCenterPreferenceKey.self) { anchors in
            GeometryReader { proxy in
                let resolved: [Int: CGPoint] = anchors.reduce(into: [:]) { dict, pair in
                    let (id, anchor) = pair
                    dict[id] = proxy[anchor]
                }
                Color.clear
                    .onAppear { centersByGameID = resolved }
                    .onChange(of: resolved) { _, newValue in
                        centersByGameID = newValue
                    }
            }
        }
    }
}

// Preference key to collect centers keyed by Game.id
private struct MatchCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [(Int, Anchor<CGPoint>)] = []
    static func reduce(value: inout [(Int, Anchor<CGPoint>)], nextValue: () -> [(Int, Anchor<CGPoint>)]) {
        value.append(contentsOf: nextValue())
    }
}

// Draw straight right-angle connectors between rounds
private struct BracketConnections: View {
    let rounds: [(round: Int, games: [Game])]
    let centersByGameID: [Int: CGPoint]
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                guard rounds.count > 1 else { return }
                
                let stroke = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                let color = Color.secondary.opacity(0.5)
                
                for r in 1..<rounds.count {
                    let prevGames = rounds[r - 1].games
                    let nextGames = rounds[r].games
                    let count = min(nextGames.count, prevGames.count / 2)
                    guard count > 0 else { continue }
                    
                    for j in 0..<count {
                        let nextGame = nextGames[j]
                        let leftIndex = 2 * j
                        let rightIndex = 2 * j + 1
                        guard prevGames.indices.contains(leftIndex),
                              prevGames.indices.contains(rightIndex) else { continue }
                        
                        let gLeft = prevGames[leftIndex]
                        let gRight = prevGames[rightIndex]
                        
                        guard let pLeft = centersByGameID[gLeft.id],
                              let pRight = centersByGameID[gRight.id],
                              let pNext = centersByGameID[nextGame.id] else { continue }
                        
                        // Draw right-angle connectors:
                        // From left feeder center, go horizontally to a midX, then vertically to pNext.y, then horizontally to next center.x
                        // Similarly from right feeder.
                        let midX = (pLeft.x + pRight.x) / 2
                        
                        var path = Path()
                        // Left branch
                        path.move(to: pLeft)
                        path.addLine(to: CGPoint(x: midX, y: pLeft.y))
                        path.addLine(to: CGPoint(x: midX, y: pNext.y))
                        path.addLine(to: CGPoint(x: pNext.x, y: pNext.y))
                        
                        // Right branch
                        path.move(to: pRight)
                        path.addLine(to: CGPoint(x: midX, y: pRight.y))
                        path.addLine(to: CGPoint(x: midX, y: pNext.y))
                        path.addLine(to: CGPoint(x: pNext.x, y: pNext.y))
                        
                        context.stroke(path, with: .color(color), style: stroke)
                    }
                }
            }
        }
    }
}

private struct RoundColumnView: View {
    let round: Int
    let games: [Game]
    let offsets: [Int: CGFloat] // game.id -> vertical offset
    
    init(round: Int, games: [Game], offsets: [Int: CGFloat] = [:]) {
        self.round = round
        self.games = games
        self.offsets = offsets
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Round \(round)")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(games, id: \.id) { game in
                MatchCardView(game: game)
                    .alignmentGuide(.top) { d in d[.top] }
                    .offset(y: offsets[game.id] ?? 0)
            }
            
            Spacer(minLength: 0)
        }
        .frame(minWidth: 220) // gives each round a column width
    }
}

private struct MatchCardView: View {
    let game: Game
    
    private var finalScoreText: String {
        if let result = game.finalResult {
            return "\(result[0]) — \(result[1])"
        } else {
            return "–"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(game.id)")
            ParticipantRow(user: game.safePlayer1, winner: game.isTheWinner(game.player1))
            Divider().padding(.horizontal, 8)
            ParticipantRow(user: game.safePlayer2, winner: game.isTheWinner(game.player2))
            
            // Final score of the match
            Text(finalScoreText)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
        )
        // Report the center anchor keyed by game id
        .anchorPreference(key: MatchCenterPreferenceKey.self, value: .center) { anchor in
            [(game.id, anchor)]
        }
    }
}

private struct ParticipantRow: View {
    let user: User
    let winner: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // If user is unknown, show a "?" placeholder avatar explicitly
            if user.isUnknown {
                AvatarView(url: nil, name: "?", email: nil, winner: winner)
                    .frame(width: 40, height: 40)
            } else {
                AvatarView(user: user, winner: winner)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.isUnknown ? "Unknown" : user.name)
                    .font(.subheadline)
                    .lineLimit(1)
                if !user.isUnknown {
                    Text("@\(user.username)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Offsets computation (align next-round card to midpoint of two feeders)
private func offsetsForRound(
    roundIndex: Int,
    gamesInRound: [Game],
    rounds: [(round: Int, games: [Game])],
    centersByGameID: [Int: CGPoint]
) -> [Int: CGFloat] {
    // First round has no offsets
    guard roundIndex > 0 else { return [:] }
    let prevGames = rounds[roundIndex - 1].games
    guard !prevGames.isEmpty else { return [:] }
    
    var offsets: [Int: CGFloat] = [:]
    let count = min(gamesInRound.count, prevGames.count / 2)
    guard count > 0 else { return [:] }
    
    for j in 0..<count {
        let nextGame = gamesInRound[j]
        let leftIndex = 2 * j
        let rightIndex = 2 * j + 1
        guard prevGames.indices.contains(leftIndex),
              prevGames.indices.contains(rightIndex) else { continue }
        
        let gLeft = prevGames[leftIndex]
        let gRight = prevGames[rightIndex]
        
        guard let pLeft = centersByGameID[gLeft.id],
              let pRight = centersByGameID[gRight.id],
              let pNext = centersByGameID[nextGame.id] else {
            continue
        }
        
        let targetY = (pLeft.y + pRight.y) / 2
        let deltaY = targetY - pNext.y
        offsets[nextGame.id] = deltaY
    }
    return offsets
}

#Preview {
    BracketsView(games: [
        Game.fake(id: 1, player1: User.me(), player2: User.opponent(), round: 1),
        Game.fake(id: 2, player1: User.opponent(), player2: User.me(), round: 1),
        Game.fake(id: 3, player1: User.opponent(), player2: User.unknown(), round: 1),
        Game.fake(id: 7, player1: User.me(), player2: User.unknown(), round: 1),
        
        Game.fake(id: 4, player1: User.me(), player2: User.opponent(), round: 2),
        Game.fake(id: 5, player1: User.unknown(), player2: User.unknown(), round: 2),
        
        Game.fake(id: 6, player1: User.me(), player2: User.opponent(), round: 3),
    ])
}
