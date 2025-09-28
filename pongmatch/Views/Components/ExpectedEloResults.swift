import SwiftUI

struct ExpectedEloResults: View {
    let game: Game
    
    @State private var isExpanded = false
    
    private struct Outcome {
        let new1: Int
        let new2: Int
        let delta1: Int
        let delta2: Int
    }
    
    private var p1Old: Int { game.player1.ranking }
    private var p2Old: Int { game.player2.ranking }
    private var kFactor: Int { game.initial_score.eloConstant }
    
    private var outcomeIfP1Wins: Outcome {
        let result = EloRating(kFactor: kFactor)
            .calculateNewRatings(
                player1Rating: p1Old,
                player2Rating: p2Old,
                didWinPlayer1: 1
            )
        let new1 = result.player1
        let new2 = result.player2
        return Outcome(
            new1: new1,
            new2: new2,
            delta1: new1 - p1Old,
            delta2: new2 - p2Old
        )
    }
    
    private var outcomeIfP2Wins: Outcome {
        let result = EloRating(kFactor: kFactor)
            .calculateNewRatings(
                player1Rating: p1Old,
                player2Rating: p2Old,
                didWinPlayer1: 0
            )
        let new1 = result.player1
        let new2 = result.player2
        return Outcome(
            new1: new1,
            new2: new2,
            delta1: new1 - p1Old,
            delta2: new2 - p2Old
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DisclosureGroup(isExpanded: $isExpanded) {
                // Details
                VStack(alignment: .leading, spacing: 10) {
                    EloOutcomeRow(
                        title: "If \(game.player1.name) wins",
                        user1: game.player1,
                        user2: game.player2,
                        old1: p1Old,
                        old2: p2Old,
                        new1: outcomeIfP1Wins.new1,
                        new2: outcomeIfP1Wins.new2,
                        delta1: outcomeIfP1Wins.delta1,
                        delta2: outcomeIfP1Wins.delta2
                    ).padding(.top, 12)
                    
                    Divider().padding(.vertical, 2)
                    
                    EloOutcomeRow(
                        title: "If \(game.player2.name) wins",
                        user1: game.player1,
                        user2: game.player2,
                        old1: p1Old,
                        old2: p2Old,
                        new1: outcomeIfP2Wins.new1,
                        new2: outcomeIfP2Wins.new2,
                        delta1: outcomeIfP2Wins.delta1,
                        delta2: outcomeIfP2Wins.delta2
                    )
                    
                    // Footnote at the very bottom
                    Text("Not recorded. Based on current ratings and K = \(kFactor).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // Smaller, compact typography for portrait fit
                .font(.footnote)
                .monospacedDigit()
                .transition(.opacity.combined(with: .move(edge: .top)))
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("Expected Elo changes")
                        .font(.headline)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.snappy) { isExpanded.toggle() } }
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                .foregroundStyle(.secondary)
        )
        .animation(.snappy, value: isExpanded)
    }
}

private struct EloOutcomeRow: View {
    let title: String
    let user1: User
    let user2: User
    let old1: Int
    let old2: Int
    let new1: Int
    let new2: Int
    let delta1: Int
    let delta2: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: "trophy")
                .labelStyle(.titleAndIcon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                // Player 1 column
                VStack(alignment: .leading, spacing: 4) {
                    AvatarView(user: user1)
                        .frame(width: 22, height: 22)
                        .accessibilityLabel(Text(user1.name))
                    HStack(spacing: 6) {
                        Text("\(old1)")
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("\(new1)")
                            .fontWeight(.semibold)
                        Text(signed(delta1))
                            .font(.caption2.weight(.bold))
                            .foregroundColor(delta1 >= 0 ? .green : .red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((delta1 >= 0 ? Color.green.opacity(0.12) : Color.red.opacity(0.12)))
                            .clipShape(.capsule)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }
                
                Spacer(minLength: 12)
                
                // Player 2 column
                VStack(alignment: .trailing, spacing: 4) {
                    AvatarView(user: user2)
                        .frame(width: 22, height: 22)
                        .accessibilityLabel(Text(user2.name))
                    HStack(spacing: 6) {
                        Text("\(old2)")
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("\(new2)")
                            .fontWeight(.semibold)
                        Text(signed(delta2))
                            .font(.caption2.weight(.bold))
                            .foregroundColor(delta2 >= 0 ? .green : .red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((delta2 >= 0 ? Color.green.opacity(0.12) : Color.red.opacity(0.12)))
                            .clipShape(.capsule)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }
            }
        }
    }
    
    private func signed(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }
}

#Preview {
    ExpectedEloResults(game: Game.fake(
        player2: User.opponent()
    ))
}
