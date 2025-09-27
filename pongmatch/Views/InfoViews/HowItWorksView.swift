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

    // A short, scannable quick-start
    private let quickSteps: [Step] = [
        .init(
            number: 1,
            title: "Create or select players",
            detail: "Start with friends or a quick anonymous match.",
            symbol: "person.crop.circle.badge.plus"
        ),
        .init(
            number: 2,
            title: "Choose rules & match type",
            detail: "Pick winning condition and Ranked or Friendly.",
            symbol: "slider.horizontal.3"
        ),
        .init(
            number: 3,
            title: "Track live or upload results",
            detail: "Keep score in real time (phone, Apple Watch, or external buttons) — or just enter the final score afterward.",
            symbol: "plus.circle"
        ),
        .init(
            number: 4,
            title: "Finish and save",
            detail: "End the match to store the result, sets and winner.",
            symbol: "checkmark.seal"
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

                    Text("A quick guide to playing, scoring, tracking your progress, and what’s coming next.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                quickStartCard
                beforeYouPlayCard
                duringMatchCard
                handsFreeControlsCard
                afterMatchCard
                communityCard
                comingSoonCard
                supportCard

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

    // MARK: Quick start

    private var quickStartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick start")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(quickSteps) { step in
                    StepRow(step: step)
                    if step.number != quickSteps.count {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .accessibilityElement(children: .contain)
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
        .accessibilityLabel("Quick start")
    }

    // MARK: Before you play

    private var beforeYouPlayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before you play")
                .font(.headline)

            FeatureRow(
                symbol: "slider.horizontal.3",
                title: "Pick rules & match type",
                detail: "Choose the winning condition and whether the match is Ranked or Friendly."
            )
            FeatureRow(
                symbol: "rosette",
                title: "Ranked matches",
                detail: "Affect your global ELO. Use for competitive games that should impact standings."
            )
            FeatureRow(
                symbol: "person.2.circle",
                title: "Friendly matches",
                detail: "Do not affect ELO. Perfect for practice or casual play."
            )
            FeatureRow(
                symbol: "checkmark.seal",
                title: "Fair and transparent",
                detail: "The scoreboard enforces rules consistently. Undo/redo keeps scoring accurate."
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
        .accessibilityLabel("Before you play")
    }

    // MARK: During the match

    private var duringMatchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("During the match")
                .font(.headline)

            FeatureRow(
                symbol: "rectangle.fill.on.rectangle.fill",
                title: "Big, clear scoreboard",
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
        .accessibilityLabel("During the match")
    }

    private var handsFreeControlsCard: some View {
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
        .accessibilityLabel("Hands‑free controls")
    }

    // MARK: After the match

    private var afterMatchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("After the match")
                .font(.headline)

            FeatureRow(
                symbol: "checkmark.seal",
                title: "Save the result",
                detail: "Finish the match to store the score, sets and winner."
            )
            FeatureRow(
                symbol: "chart.line.uptrend.xyaxis",
                title: "Stats & insights",
                detail: "Track win rate, streaks, and per‑set breakdowns to understand your progress."
            )
            FeatureRow(
                symbol: "person.2",
                title: "Head‑to‑head",
                detail: "See who leads each rivalry and how it evolves over time."
            )
            FeatureRow(
                symbol: "chart.bar.fill",
                title: "ELO basics",
                detail: "Beating higher‑rated players gains more points; losing to lower‑rated players costs more. Only ranked matches change ELO."
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
        .accessibilityLabel("After the match")
    }

    // MARK: Community

    private var communityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Community & progress")
                .font(.headline)

            FeatureRow(
                symbol: "person.crop.circle.badge.plus",
                title: "Follow other players",
                detail: "Add friends to see their progress and compare results."
            )
            FeatureRow(
                symbol: "rosette",
                title: "Leaderboards",
                detail: "Compare rankings, win rate and streaks across your group."
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
        .accessibilityLabel("Community and progress")
    }

    // MARK: Coming soon

    private var comingSoonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
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

            Text("These features are in active development and will roll out in upcoming versions.")
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
        .accessibilityLabel("What’s next, coming soon")
    }

    // MARK: Support

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
        .accessibilityLabel("Support development. Buy me a Coffee.")
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
