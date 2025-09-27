import SwiftUI

struct HowItWorksView: View {
    @Environment(\.dismiss) private var dismiss

    struct Step: Identifiable {
        let id = UUID()
        let number: Int
        let title: String
        let detail: String
        let symbol: String
    }

    private let steps: [Step] = [
        .init(
            number: 1,
            title: "Create or select players",
            detail: "Add friends or play a quick match anonymously. You can start a match anytime.",
            symbol: "person.crop.circle.badge.plus"
        ),
        .init(
            number: 2,
            title: "Start a match and keep score",
            detail: "Tap the player panels to add points. Undo/redo keeps scoring accurate.",
            symbol: "plus.circle"
        ),
        .init(
            number: 3,
            title: "Use Apple Watch or external buttons",
            detail: "Keep score hands‑free from your wrist or with a small Bluetooth remote.",
            symbol: "applewatch"
        ),
        .init(
            number: 4,
            title: "Mirror the live scoreboard",
            detail: "AirPlay to a TV or share your screen so everyone can follow along.",
            symbol: "airplayvideo"
        ),
        .init(
            number: 5,
            title: "Finish and save the result",
            detail: "End the match to store the score, sets and winner in your history.",
            symbol: "checkmark.seal"
        ),
        .init(
            number: 6,
            title: "Review stats and head‑to‑head",
            detail: "Track progress, compare with friends and see who leads each rivalry.",
            symbol: "chart.line.uptrend.xyaxis"
        ),
        .init(
            number: 7,
            title: "Organize tournaments & leagues",
            detail: "Coming soon: create brackets, round‑robins and longer leagues to crown a champion.",
            symbol: "trophy"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text("How it works")
                        .font(.title).bold()
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Keep score easily, track your progress, compare with friends, and soon—run tournaments and leagues.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                stepsCard
                liveScoreboardCard
                friendsAndHeadToHeadCard
                statsCard
                controlsCard
                supportCard      // Prominent CTA
                comingSoonCard   // Still includes a smaller link

                Spacer(minLength: 8)

                Button(action: { dismiss() }) {
                    Text("Got it")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("howItWorks.gotItButton")
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }

    // MARK: - Subviews

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.teal.opacity(0.95),
                            Color.green.opacity(0.9),
                            Color.orange.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)

            HStack(spacing: 24) {
                Image(systemName: "sportscourt")
                    .font(.system(size: 52, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Image(systemName: "chart.bar")
                    .font(.system(size: 52, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                Image(systemName: "person.2")
                    .font(.system(size: 52, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
            }
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score matches, see stats and play with friends")
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(steps) { step in
                StepRow(step: step)
                if step.number != steps.count {
                    Divider().padding(.leading, 44)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Getting started")
    }

    private var liveScoreboardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live and easy scoreboard")
                .font(.headline)

            FeatureRow(
                symbol: "rectangle.fill.on.rectangle.fill",
                title: "Big, clear score",
                detail: "Tap to add points. Match point and server indicators keep things clear."
            )
            FeatureRow(
                symbol: "airplayvideo",
                title: "Mirror to TV",
                detail: "Use AirPlay or screen mirroring so everyone can follow the match."
            )
            FeatureRow(
                symbol: "arrow.uturn.left",
                title: "Undo / Redo",
                detail: "Correct mistakes instantly without losing the flow of the match."
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Live and easy scoreboard")
    }

    private var friendsAndHeadToHeadCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends & head‑to‑head")
                .font(.headline)

            FeatureRow(
                symbol: "person.2",
                title: "Add friends",
                detail: "Track matches with friends and see everyone’s progress."
            )
            FeatureRow(
                symbol: "chart.line.uptrend.xyaxis",
                title: "Head‑to‑head",
                detail: "See who leads each rivalry and how it evolves over time."
            )
            FeatureRow(
                symbol: "rosette",
                title: "Leaderboards",
                detail: "Compare win rate and streaks across your group."
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Friends and head‑to‑head")
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats & insights")
                .font(.headline)

            FeatureRow(
                symbol: "percent",
                title: "Win rate",
                detail: "Track your performance across sets and matches."
            )
            FeatureRow(
                symbol: "flame",
                title: "Streaks",
                detail: "See hot streaks and momentum over time."
            )
            FeatureRow(
                symbol: "square.grid.2x2",
                title: "Per‑set breakdown",
                detail: "Analyze sets and games to understand trends."
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Stats and insights")
    }

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hands‑free controls")
                .font(.headline)

            NavigationLink {
                WatchSyncInfoView()
            } label: {
                LinkRow(
                    symbol: "applewatch",
                    title: "Apple Watch sync",
                    detail: "Keep score from your wrist. Works live with your iPhone."
                )
            }

            NavigationLink {
                ExternalButtonInfoView()
            } label: {
                LinkRow(
                    symbol: "button.horizontal.top.press",
                    title: "External button control",
                    detail: "Use a mini gamepad or shutter remote to score without looking at your phone."
                )
            }

            Text("Great when mirroring the scoreboard to a TV, or when you want to keep your phone away.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Hands‑free controls")
    }

    // Prominent support card with a large CTA button
    private var supportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support development")
                .font(.headline)

            Text("Enjoying the app? Tips help keep it fast, clean, and bring tournaments & leagues sooner.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink {
                BuyMeACoffeeView()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.headline.weight(.semibold))
                        .accessibilityHidden(true)
                    Text("Buy me a Coffee")
                        .font(.headline)
                        .bold()
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .opacity(0.9)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.brown.opacity(0.95),
                                    Color.orange.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 6)
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .accessibilityIdentifier("howItWorks.buyCoffeeCTA")

            Text("100% of your tip goes to development. Thank you! ❤️")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Support development. Buy me a Coffee.")
    }

    private var comingSoonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Clear, explicit title
            Text("What’s next (coming soon)")
                .font(.headline)

            FeatureRow(
                symbol: "trophy",
                title: "Tournaments & leagues",
                detail: "Brackets, round‑robins and long‑form leagues to crown a champion."
            )
            FeatureRow(
                symbol: "circle.grid.3x3",
                title: "Round‑robins",
                detail: "Everyone plays everyone for fair standings."
            )
            FeatureRow(
                symbol: "calendar",
                title: "Leagues",
                detail: "Season‑style competitions with fixtures and tables."
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
                .opacity(0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("What’s next, coming soon")
    }
}

// MARK: - Rows

private struct StepRow: View {
    let step: HowItWorksView.Step

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            numberBadge(step.number)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(step.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 8)

                    Image(systemName: step.symbol)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }

                Text(step.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.number). \(step.title). \(step.detail)")
    }

    private func numberBadge(_ number: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.15))
            Text("\(number)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.accentColor)
        }
        .frame(width: 28, height: 28)
        .accessibilityHidden(true)
    }
}

private struct FeatureRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .frame(width: 20)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
    }
}

private struct LinkRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .frame(width: 20)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
    }
}

#Preview {
    NavigationStack {
        HowItWorksView()
    }
}
