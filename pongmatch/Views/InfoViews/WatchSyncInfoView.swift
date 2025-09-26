import SwiftUI

struct WatchSyncInfoView: View {
    @Environment(\.dismiss) private var dismiss

    struct WatchSyncStep: Identifiable {
        let id = UUID()
        let number: Int
        let title: String
        let detail: String
        let symbol: String
    }

    // Tutorial steps content
    private let steps: [WatchSyncStep] = [
        .init(
            number: 1,
            title: "Install on your Watch",
            detail: "Get the app on your iPhone. The Apple Watch companion installs from the Watch app.",
            symbol: "applewatch"
        ),
        .init(
            number: 2,
            title: "Open the scoreboard",
            detail: "Start a match on your iPhone or on your Apple Watch—your choice.",
            symbol: "sportscourt"
        ),
        .init(
            number: 3,
            title: "Stay perfectly in sync",
            detail: "Every point you add shows up instantly on both devices—perfect when you’re mirroring the scoreboard to a TV with AirPlay.",
            symbol: "arrow.triangle.2.circlepath"
        ),
        .init(
            number: 4,
            title: "Go phone‑free",
            detail: "Prefer to keep it simple? Use the watch on its own and leave your iPhone behind.",
            symbol: "figure.walk"
        ),
        .init(
            number: 5,
            title: "Finish and send to iPhone",
            detail: "End the match on your watch and send it to your iPhone to sync with the cloud.",
            symbol: "icloud.and.arrow.up"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text("Track the scoreboard from your Apple Watch")
                        .font(.title).bold()
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Keep score from your wrist—perfect for when your iPhone is tucked away.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                stepsCard

                Spacer(minLength: 8)

                Button(action: { dismiss() }) {
                    Text("Got it")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("watchSyncInfo.gotItButton")
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        .navigationTitle("Apple Watch Sync")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.9),
                            Color.green.opacity(0.9)
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
                Image(systemName: "iphone")
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Image(systemName: "applewatch")
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
            }
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your iPhone and Apple Watch stay in sync")
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
        .accessibilityLabel("How it works")
    }
}

private struct StepRow: View {
    let step: WatchSyncInfoView.WatchSyncStep

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

#Preview {
    NavigationStack {
        WatchSyncInfoView()
    }
}
