import SwiftUI

struct ExternalButtonInfoView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Integration model

    enum Integration: String, CaseIterable, Identifiable {
        case flic
        case gamepad
        case volume

        var id: String { rawValue }

        var title: String {
            switch self {
            case .flic: return "Flic Buttons"
            case .gamepad: return "Mini Gamepad"
            case .volume: return "Volume Button"
            }
        }

        var iconSystemName: String {
            switch self {
            case .flic: return "circle.circle" // representative; Flic doesn’t have an SF Symbol
            case .gamepad: return "gamecontroller"
            case .volume: return "camera.circle"
            }
        }
    }

    struct Step: Identifiable {
        let id = UUID()
        let number: Int
        let title: String
        let detail: String
        let symbol: String
    }

    // MARK: - State

    @State private var selected: Integration = .flic

    // MARK: - Content providers

    private func steps(for integration: Integration) -> [Step] {
        switch integration {
        case .flic:
            return [
                .init(
                    number: 1,
                    title: "Attach to each side",
                    detail: "Place one Flic button on each side of the court so players can reach them.",
                    symbol: "mappin.and.ellipse"
                ),
                .init(
                    number: 2,
                    title: "Set up Flic buttons",
                    detail: "Use the “Set up Flic buttons” option in the app to pair and assign each button.",
                    symbol: "link.circle"
                ),
                .init(
                    number: 3,
                    title: "Press to score",
                    detail: "Press the button on a court side to increase that side’s score.",
                    symbol: "plus.circle"
                ),
                .init(
                    number: 4,
                    title: "Long press to undo",
                    detail: "Long press either button to undo the last point.",
                    symbol: "arrow.uturn.left"
                ),
                .init(
                    number: 5,
                    title: "Double press to redo",
                    detail: "Double press either button to redo the last undone action.",
                    symbol: "arrow.uturn.right"
                )
            ]
        case .gamepad:
            return [
                .init(
                    number: 1,
                    title: "Pair your controller",
                    detail: "Turn on the mini gamepad and pair it in Settings → Bluetooth.",
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
                    detail: "Player 1+, Player 2+, Undo, Redo.",
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
        case .volume:
            return [
                .init(
                    number: 1,
                    title: "Pair your remote",
                    detail: "Turn on the Bluetooth shutter remote and pair it in Settings → Bluetooth.",
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
                    detail: "Single, double, triple press to score and undo.",
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
        }
    }

    private func mappingRows(for integration: Integration) -> [MappingRow.Model] {
        switch integration {
        case .flic:
            return [
                .init(symbol: "plus.circle", title: "Single press (left/right)", detail: "Increase the score for that court side."),
                .init(symbol: "arrow.uturn.left", title: "Long press (any side)", detail: "Undo the last point."),
                .init(symbol: "arrow.uturn.right", title: "Double press (any side)", detail: "Redo the last undone action.")
            ]
        case .gamepad:
            return [
                .init(symbol: "plus.circle", title: "Player 1 +", detail: "Increase Player 1’s score."),
                .init(symbol: "plus.circle", title: "Player 2 +", detail: "Increase Player 2’s score."),
                .init(symbol: "arrow.uturn.left", title: "Undo", detail: "Revert the last action."),
                .init(symbol: "arrow.uturn.right", title: "Redo", detail: "Re‑apply the last undone action.")
            ]
        case .volume:
            return [
                .init(symbol: "1.circle", title: "Single press", detail: "Player 1 +"),
                .init(symbol: "2.circle", title: "Double press", detail: "Player 2 +"),
                .init(symbol: "3.circle", title: "Triple press", detail: "Undo")
            ]
        }
    }

    private struct AccessoryLink {
        let icon: String
        let title: String
        let description: String
        let url: URL
    }

    private func accessory(for integration: Integration) -> AccessoryLink {
        switch integration {
        case .flic:
            return .init(
                icon: "circle.circle",
                title: "Flic 2 Smart Button",
                description: "Attachable wireless buttons. Assign each side and control scoring with single, double, and long press.",
                url: URL(string: "https://flic.io/flic2")!
            )
        case .gamepad:
            return .init(
                icon: "gamecontroller",
                title: "Mini Gamepad",
                description: "Compact controller with dedicated buttons for Player 1, Player 2, Undo, and Redo.",
                url: URL(string: "https://www.amazon.es/dp/B0C7BC5QM4")!
            )
        case .volume:
            return .init(
                icon: "camera.circle",
                title: "Bluetooth shutter remote",
                description: "Uses volume up/down. Single press for Player 1, double for Player 2, triple to undo.",
                url: URL(string: "https://www.amazon.es/Temporizador-Fotografía-Disparador-Automático-Compatibilidad/dp/B0D2HG7ZLJ")!
            )
        }
    }

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

                // Segmented control for integrations
                Picker("Integration", selection: $selected) {
                    ForEach(Integration.allCases) { integration in
                        Label(integration.title, systemImage: integration.iconSystemName)
                            .tag(integration)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("externalButtonInfo.integrationPicker")

                stepsCard(for: selected)
                mappingsCard(for: selected)
                recommendationsCard(for: selected)

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
        .navigationTitle("External Button Control")
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
        .accessibilityLabel("Control the scoreboard with a gamepad, Flic buttons, or shutter remote")
    }

    private func stepsCard(for integration: Integration) -> some View {
        let steps = steps(for: integration)
        return VStack(alignment: .leading, spacing: 16) {
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
        .accessibilityLabel("\(integration.title) - How it works")
    }

    private func mappingsCard(for integration: Integration) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Default button mapping")
                .font(.headline)

            switch integration {
            case .gamepad:
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "gamecontroller")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Mini Gamepad")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(mappingRows(for: .gamepad)) { model in
                        MappingRow(model: model)
                    }
                }
            case .volume:
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.circle")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Volume shutter remote")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(mappingRows(for: .volume)) { model in
                        MappingRow(model: model)
                    }
                }
            case .flic:
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.circle")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Flic Buttons")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(mappingRows(for: .flic)) { model in
                        MappingRow(model: model)
                    }
                }

                Text("Tip: Assign one button to each court side. You can change the assignment mode in settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if integration != .flic {
                Divider()
                Text("Tip: Many remotes act like keyboards or volume buttons. If your controller has modes, use the one that works as a Bluetooth keyboard/media remote.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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
        .accessibilityLabel("\(integration.title) - Default button mapping")
    }

    private func recommendationsCard(for integration: Integration) -> some View {
        let accessory = accessory(for: integration)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Recommended accessory")
                .font(.headline)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: accessory.icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(accessory.title)
                        .font(.subheadline.weight(.semibold))
                    Text(accessory.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Link("View", destination: accessory.url)
                        .font(.footnote.weight(.semibold))
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
        .accessibilityLabel("\(integration.title) - Recommended accessory")
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
    struct Model: Identifiable {
        let id = UUID()
        let symbol: String
        let title: String
        let detail: String
    }

    let model: Model

    init(symbol: String, title: String, detail: String) {
        self.model = .init(symbol: symbol, title: title, detail: detail)
    }

    init(model: Model) {
        self.model = model
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: model.symbol)
                .font(.headline)
                .frame(width: 20)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(model.title)
                    .font(.subheadline.weight(.semibold))
                Text(model.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(model.title). \(model.detail)")
    }
}

#Preview {
    NavigationStack {
        ExternalButtonInfoView()
    }
}
