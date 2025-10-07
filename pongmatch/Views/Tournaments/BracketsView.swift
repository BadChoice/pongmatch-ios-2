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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 24) {
                ForEach(rounds, id: \.round) { round in
                    RoundColumnView(round: round.round, games: round.games)
                }
            }
            .padding()
        }
    }
}

private struct RoundColumnView: View {
    let round: Int
    let games: [Game]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Round \(round)")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(games, id: \.id) { game in
                MatchCardView(game: game)
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

#Preview {
    BracketsView(games: [
        Game.fake(id: 1, player1: User.me(), player2: User.opponent(), round: 1),
        Game.fake(id: 2, player1: User.opponent(), player2: User.me(), round: 1),
        Game.fake(id: 3, player1: User.opponent(), player2: User.unknown(), round: 1),
        Game.fake(id: 3, player1: User.me(), player2: User.unknown(), round: 1),
        
        Game.fake(id: 4, player1: User.me(), player2: User.opponent(), round: 2),
        Game.fake(id: 5, player1: User.unknown(), player2: User.unknown(), round: 2),
        
        Game.fake(id: 6, player1: User.me(), player2: User.opponent(), round: 3),
    ])
}
