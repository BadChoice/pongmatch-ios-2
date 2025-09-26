import SwiftUI
import StoreKit

struct BuyMeACoffeeView: View {
    @StateObject private var store = CoffeeTipStore()

    // Customize which options to show
    let options: [InAppPurchaseProducts]
    // Called after a successful purchase of an option
    var onTip: (InAppPurchaseProducts) -> Void

    init(
        options: [InAppPurchaseProducts] = InAppPurchaseProducts.allCases,
        onTip: @escaping (InAppPurchaseProducts) -> Void = { _ in }
    ) {
        self.options = options
        self.onTip = onTip
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                optionGrid
                footerText
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Buy Me a Coffee")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Ensure products are loaded (init already triggers, but safe to refresh here)
            await store.reloadProducts()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 110, height: 110)

                Image(systemName: "cup.and.saucer.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.brown)
                    .font(.system(size: 48, weight: .bold))
                    .accessibilityHidden(true)
            }

            Text("Fuel the Journey")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("If you enjoy the app, a coffee goes a long way. Your tip helps me keep it clean, fast, and improving.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var optionGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(options, id: \.self) { option in
                OptionCard(
                    option: option,
                    priceText: store.displayPrice(for: option),
                    isLoading: store.isLoading || store.displayPrice(for: option) == nil,
                    isPurchasing: store.purchaseInFlight == option
                ) {
                    Task {
                        let success = await store.purchase(option)
                        if success {
                            onTip(option)
                        }
                    }
                }
            }
        }
        .padding(.top, 4)
        .accessibilityElement(children: .contain)
    }

    private var footerText: some View {
        VStack(spacing: 6) {
            Text("100% of your tip goes directly to supporting development.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Thank you for keeping the app ad-free and focused. ❤️")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 8)
    }
}

private struct OptionCard: View {
    let option: InAppPurchaseProducts
    let priceText: String?
    let isLoading: Bool
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .scaleEffect(option.iconScale)
                    .foregroundStyle(Color.brown)
                    .padding(.top, 10)

                Text(option.description)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(priceText ?? (isLoading ? "Loading…" : "—"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PressableCardStyle())
        .disabled(isLoading || isPurchasing || priceText == nil)
        .overlay(alignment: .topTrailing) {
            if isPurchasing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
                    .padding(10)
            }
        }
        .accessibilityLabel("\(option.description) coffee, \(priceText ?? "price loading"). Tap to tip.")
    }
}

private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        BuyMeACoffeeView { option in
            print("Tipped: \(option.description)")
        }
        .navigationTitle("Support")
    }
}
