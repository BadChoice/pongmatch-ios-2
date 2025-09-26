import SwiftUI

struct BuyMeACoffeeView: View {
    struct TipOption: Identifiable, Hashable {
        enum Size: String, CaseIterable {
            case small, medium, large, extraLarge

            var title: String {
                switch self {
                case .small: return "Small"
                case .medium: return "Medium"
                case .large: return "Large"
                case .extraLarge: return "Extra Large"
                }
            }

            // Used to subtly scale the cup icon for each size
            var iconScale: CGFloat {
                switch self {
                case .small: return 1.0
                case .medium: return 1.15
                case .large: return 1.3
                case .extraLarge: return 1.45
                }
            }
        }

        let id = UUID()
        let size: Size
        let price: Decimal

        static let defaultOptions: [TipOption] = [
            .init(size: .small, price: 3),
            .init(size: .medium, price: 5),
            .init(size: .large, price: 8),
            .init(size: .extraLarge, price: 12)
        ]
    }

    // Customize options and handle selection with onTip
    let options: [TipOption]
    var onTip: (TipOption) -> Void

    init(
        options: [TipOption] = TipOption.defaultOptions,
        onTip: @escaping (TipOption) -> Void = { _ in }
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
            ForEach(options) { option in
                OptionCard(option: option) {
                    onTip(option) // Tap triggers the buy/tip process immediately
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

    private func formattedCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$\(amount)"
    }
}

private struct OptionCard: View {
    let option: BuyMeACoffeeView.TipOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .scaleEffect(option.size.iconScale)
                    .foregroundStyle(Color.brown)
                    .padding(.top, 10)

                Text(option.size.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(formattedCurrency(option.price))
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
        .accessibilityLabel("\(option.size.title) coffee, \(formattedCurrency(option.price)). Tap to tip.")
    }

    private func formattedCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$\(amount)"
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
    Group {
        NavigationStack {
            BuyMeACoffeeView { option in
                print("Tip now: \(option.size.title) - \(option.price)")
            }
            .navigationTitle("Support")
        }

        NavigationStack {
            BuyMeACoffeeView(
                options: [
                    .init(size: .small, price: 2),
                    .init(size: .medium, price: 4),
                    .init(size: .large, price: 7),
                    .init(size: .extraLarge, price: 10)
                ]
            ) { option in
                print("Tip now: \(option.size.title) - \(option.price)")
            }
            .preferredColorScheme(.light)
            .navigationTitle("Support")
        }
    }
}
