// CoffeeTipStore.swift
import Foundation
import Combine
import StoreKit

@MainActor
final class CoffeeTipStore: ObservableObject {
    @Published private(set) var products: [InAppPurchaseProducts: Product] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var purchaseInFlight: InAppPurchaseProducts?

    init() {
        Task {
            await reloadProducts()
            await observeTransactions()
        }
    }

    func reloadProducts() async {
        isLoading = true
        defer { isLoading = false }

        let ids = InAppPurchaseProducts.allCases.map(\.rawValue)

        do {
            let storeProducts = try await Product.products(for: ids)

            // Map by ID first for safety, then to enum
            let byID = Dictionary(uniqueKeysWithValues: storeProducts.map { ($0.id, $0) })
            var mapped: [InAppPurchaseProducts: Product] = [:]
            for option in InAppPurchaseProducts.allCases {
                if let p = byID[option.rawValue] {
                    mapped[option] = p
                }
            }
            self.products = mapped
        } catch {
            // You might want to surface this error to the UI in production
            print("Failed to load products: \(error)")
            self.products = [:]
        }
    }

    func displayPrice(for option: InAppPurchaseProducts) -> String? {
        products[option]?.displayPrice
    }

    func purchase(_ option: InAppPurchaseProducts) async -> Bool {
        guard let product = products[option] else {
            print("Product not loaded for \(option.rawValue)")
            return false
        }

        purchaseInFlight = option
        defer { purchaseInFlight = nil }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                // For consumables, finish immediately once granted
                await transaction.finish()
                return true

            case .userCancelled:
                return false

            case .pending:
                // You could surface a pending state to the UI
                return false

            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    private func observeTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                // Grant the entitlement here if needed (consumables typically grant immediately on success)
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case verificationFailed
    }
}
