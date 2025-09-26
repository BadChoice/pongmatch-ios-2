import SwiftUI

struct ExternalButtonInfoView: View {
    @Environment(\.dismiss) private var dismiss

    struct Step: Identifiable {
        let id = UUID()
        let number: Int
        let title: String
        let detail: String
        let symbol: String
    }

    // MARK: - Content

    private let steps: [Step] = [
        .init(
            number: 1,
            title: "Pair your controller",
            detail: "Turn on the mini gamepad or shutter remote and pair it in Settings → Bluetooth.",
            symbol: "bluetooth"
        ),
        .init(
            number: 2,
            title: "Open the scoreboard",
            detail: "Start a match—your button presses will control the score.",
            symbol: "sportscourt"
        ),
        .init(
            number: 3,
            title: "Use the buttons",
            detail: "Gamepad: Player 1+, Player 2+, Undo, Redo.\nShutter: single, double, triple press to score and undo.",
            symbol: "rectangle.and.hand.point.up.left.filled"
        ),
        .init(
            number: 4,
            title: "Play hands‑free",
            detail: "Keep your phone away and focus on the match. Great when mirroring the scoreboard to a TV with AirPlay.",
            symbol: "airplayvideo"
        ),
        .init(
            number: 5,
            title: "Finish and review",
            detail: "End the match anytime. Undo/redo keeps your scoring accurate.",
            symbol: "checkmark.circle"
        )
    ]

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text("Use an external button to keep score")
                        .font(.title).bold()
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Score points without looking at your phone—perfect for fast rallies or when your hands are full.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                stepsCard
                mappingsCard
                recommendationsCard

                Spacer(minLength: 8)

                Button(action: { dismiss() }) {
                    Text("Got it")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("externalButtonInfo.gotItButton")
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        // Let content extend under the navigation bar for a full-bleed hero,
        // matching the Apple Watch sync screen behavior.
        .navigationTitle("External Button Control")
        .navigationBarTitleDisplayMode(.inline)
        // Make the navigation bar overlay the scroll view (transparent background).
        //.toolbarBackground(.hidden, for: .navigationBar)
        //.toolbarBorderHidden(true, for: .navigationBar)
        .background(Color(.systemBackground)) // Ensure correct background behind the nav bar
    }

    // MARK: - Subviews

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.95),
                            Color.blue.opacity(0.9)
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

            HStack(spacing: 28) {
                Image(systemName: "gamecontroller")
                    .font(.system(size: 54, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Image(systemName: "camera.circle")
                    .font(.system(size: 54, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
            }
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Control the scoreboard with a gamepad or shutter remote")
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

    private var mappingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Default button mapping")
                .font(.headline)

            // Gamepad
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Mini Gamepad")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                MappingRow(
                    symbol: "plus.circle",
                    title: "Player 1 +",
                    detail: "Increase Player 1’s score."
                )
                MappingRow(
                    symbol: "plus.circle",
                    title: "Player 2 +",
                    detail: "Increase Player 2’s score."
                )
                MappingRow(
                    symbol: "arrow.uturn.left",
                    title: "Undo",
                    detail: "Revert the last action."
                )
                MappingRow(
                    symbol: "arrow.uturn.right",
                    title: "Redo",
                    detail: "Re‑apply the last undone action."
                )
            }

            Divider()

            // Shutter remote
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.circle")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Volume shutter remote")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                MappingRow(
                    symbol: "1.circle",
                    title: "Single press",
                    detail: "Player 1 +"
                )
                MappingRow(
                    symbol: "2.circle",
                    title: "Double press",
                    detail: "Player 2 +"
                )
                MappingRow(
                    symbol: "3.circle",
                    title: "Triple press",
                    detail: "Undo"
                )
            }

            Text("Tip: Many remotes act like keyboards or volume buttons. If your controller has modes, use the one that works as a Bluetooth keyboard/media remote.")
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
        .accessibilityLabel("Default button mapping")
    }

    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended accessories")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "gamecontroller")
                        .foregroundStyle(.secondary)
                        .frame(width:24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mini Gamepad")
                            .font(.subheadline.weight(.semibold))
                        Text("Compact controller with dedicated buttons for Player 1, Player 2, Undo, and Redo.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Link("View on Amazon",
                             destination: URL(string: "https://www.amazon.es/dp/B0C7BC5QM4")!)
                            .font(.footnote.weight(.semibold))
                    }
                }

                Spacer().frame(height: 8)
                
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "camera.circle")
                        .foregroundStyle(.secondary)
                        .frame(width:24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bluetooth shutter remote")
                            .font(.subheadline.weight(.semibold))
                        Text("Uses volume up/down. Single press for Player 1, double for Player 2, triple to undo.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Link("View on Amazon",
                             destination: URL(string: "https://www.amazon.es/Temporizador-Fotografía-Disparador-Automático-Compatibilidad/dp/B0D2HG7ZLJ")!)
                            .font(.footnote.weight(.semibold))
                    }
                }
            }

            Text("We’re not affiliated with these products. Availability may change.")
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
        .accessibilityLabel("Recommended accessories")
    }
}

// MARK: - Rows

private struct StepRow: View {
    let step: ExternalButtonInfoView.Step

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

private struct MappingRow: View {
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

#Preview {
    NavigationStack {
        ExternalButtonInfoView()
    }
}
