import SwiftUI

struct DisputeResultView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    let game: Game

    @State private var reason: String = ""
    @State private var showConfirm: Bool = false
    @StateObject private var disputing = ApiAction()

    private var trimmedReason: String {
        reason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValidReason: Bool {
        let count = trimmedReason.count
        return count >= 6 && count <= 255
    }

    private var remainingCharacters: Int {
        max(0, 255 - reason.count)
    }

    private var opponentName: String {
        guard let me = auth.user else { return "the other player" }
        return me.id == game.player1.id ? game.player2.name : game.player1.name
    }

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .accessibilityHidden(true)

            header

            if game.ranking_type != .competitive {
                RankedOnlyBanner()
            } else if !game.canBeDisputed() {
                CannotDisputeBanner()
            }

            if showConfirm {
                confirmStep
            } else {
                formStep
            }

            if let errorMessage = disputing.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .accessibilityIdentifier("dispute.errorMessage")
            }

            Spacer(minLength: 0)

            bottomButtons
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .interactiveDismissDisabled(disputing.loading)
        .onChange(of: reason) { _, newValue in
            if newValue.count > 255 {
                reason = String(newValue.prefix(255))
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "flag")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(showConfirm ? "Confirm dispute" : "Dispute result")
                    .font(.headline)
                Text("Explain why you disagree with the uploaded result.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Close")
        }
        .padding(.top, 12)
    }

    private var formStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reason (required)")
                .font(.subheadline.weight(.semibold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))

                TextEditor(text: $reason)
                    .padding(10)
                    .frame(minHeight: 120, maxHeight: 160)
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("dispute.reasonTextEditor")

                if reason.isEmpty {
                    Text("Enter a short explanation (6–255 characters)")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }

            HStack {
                if !trimmedReason.isEmpty && trimmedReason.count < 6 {
                    Text("Minimum 6 characters.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(" ")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(reason.count)/255")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(reason.count > 255 || trimmedReason.count < 6 ? .red : .secondary)
                    .accessibilityIdentifier("dispute.charCount")
            }

            infoBlock
        }
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Only ranked matches can be disputed.", systemImage: "rosette")
            Label("If your dispute is accepted, ELO changes for this match will be reverted.", systemImage: "chart.line.downtrend.xyaxis")
            Label("If the match belongs to a league or tournament, it can be replayed; otherwise it will be canceled.", systemImage: "trophy")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Only ranked matches can be disputed. If your dispute is accepted, ELO changes will be reverted. If the match belongs to a league or tournament, it can be replayed; otherwise it will be canceled.")
    }

    private var confirmStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before you continue")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .foregroundStyle(.secondary)
                    Text("We’ll notify \(opponentName) to accept or reject your dispute. If they don’t accept, Pongmatch administrators will review and decide the result.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .foregroundStyle(.secondary)
                    Text("If your dispute is accepted, ELO changes for this match will be reverted.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "trophy")
                        .foregroundStyle(.secondary)
                    Text("If the match belongs to a league or tournament, it can be played again. Otherwise, the match will be canceled.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider().padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your reason")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("“\(trimmedReason)”")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            if showConfirm {
                Button(role: .cancel) {
                    withAnimation { showConfirm = false }
                } label: {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(disputing.loading)

                Button {
                    submit()
                } label: {
                    HStack(spacing: 8) {
                        if disputing.loading { ProgressView() }
                        Text("Start Dispute")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(disputing.loading)
                .accessibilityIdentifier("dispute.startButton")
            } else {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(disputing.loading)

                Button {
                    withAnimation { showConfirm = true }
                } label: {
                    Text("Continue")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!(game.canBeDisputed() && isValidReason) || disputing.loading)
                .accessibilityIdentifier("dispute.continueButton")
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func submit() {
        guard !disputing.loading else { return }
        Task {
            let success = await disputing.run {
                _ = try await auth.api.games.dispute(game, reason: trimmedReason)
            }
            if success {
                dismiss()
            }
        }
    }
}

// MARK: - Banners

private struct RankedOnlyBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 4) {
                Text("Only ranked matches can be disputed")
                    .font(.subheadline.weight(.semibold))
                Text("This match is Friendly and does not affect ELO, so it cannot be disputed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Only ranked matches can be disputed. This match is Friendly and cannot be disputed.")
    }
}

private struct CannotDisputeBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 4) {
                Text("This match cannot be disputed")
                    .font(.subheadline.weight(.semibold))
                Text("Only finished ranked matches can be disputed. Please try again later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("This match cannot be disputed. Only finished ranked matches can be disputed.")
    }
}

#Preview {
    @Previewable @State var show = true
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")

    return NavigationStack {}.sheet(isPresented: $show) {
        DisputeResultView(game: Game.fake(status: .finished))
            .environmentObject(auth)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
    }
}
