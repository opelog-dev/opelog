import Combine
import Foundation
import StoreKit

/// StoreKit 2 lifetime Premium (`opelog_premium_lifetime` non-consumable). Local-first; no server receipt validation.
///
/// **App Store Connect**
/// - Create an In-App Purchase with type **Non-Consumable**.
/// - Product ID must be exactly: `opelog_premium_lifetime`
///
/// **Local testing (Xcode)**
/// - Editor → Add Configuration → **StoreKit Configuration** file; add a non-consumable with the same product ID.
/// - Scheme → Run → Options → **StoreKit Configuration** → select that file.
/// - If the product fails to load (`Product.products` empty), the app continues; `PremiumView` shows a soft “store unavailable” message instead of crashing.
@MainActor
final class PurchaseManager: ObservableObject {
    /// Free tier: max active (non-archived) items. Archived items do not count.
    static let freeActiveItemLimit = 15

    /// Must match the Non-Consumable product ID in App Store Connect / `.storekit`.
    static let premiumProductID = "opelog_premium_lifetime"

    @Published private(set) var isPremium: Bool = false
    @Published private(set) var didResolveEntitlements: Bool = false
    @Published private(set) var premiumProduct: Product?
    @Published private(set) var isLoadingProduct: Bool = false

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = Task { await self.listenForTransactionUpdates() }
        Task { await self.refreshEntitlements() }
        Task { await self.loadPremiumProduct() }
    }

    deinit {
        transactionListener?.cancel()
    }

    /// Whether a free user may open the add-item flow (Premium or under active cap).
    func canAddActiveItem(currentActiveCount: Int) -> Bool {
        isPremium || currentActiveCount < Self.freeActiveItemLimit
    }

    func loadPremiumProduct() async {
        isLoadingProduct = true
        defer { isLoadingProduct = false }
        do {
            let products = try await Product.products(for: [Self.premiumProductID])
            premiumProduct = products.first
        } catch {
            premiumProduct = nil
        }
    }

    func refreshEntitlements() async {
        var premium = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.productID == Self.premiumProductID else { continue }
            if transaction.revocationDate == nil {
                premium = true
            }
        }
        isPremium = premium
        didResolveEntitlements = true
    }

    enum PurchaseFlowResult: Equatable {
        case purchased
        case userCancelled
        case pending
        case failedUserMessage(String)
    }

    func purchasePremium() async -> PurchaseFlowResult {
        guard let premiumProduct else {
            return .failedUserMessage(L10n.premiumStoreUnavailable)
        }
        do {
            let result = try await premiumProduct.purchase()
            switch result {
            case .success(let verification):
                do {
                    let transaction = try Self.verify(verification)
                    guard transaction.productID == Self.premiumProductID else {
                        return .failedUserMessage(L10n.premiumPurchaseFailed)
                    }
                    await transaction.finish()
                    await refreshEntitlements()
                    return .purchased
                } catch {
                    return .failedUserMessage(L10n.premiumPurchaseFailed)
                }
            case .userCancelled:
                return .userCancelled
            case .pending:
                return .pending
            @unknown default:
                return .failedUserMessage(L10n.premiumPurchaseFailed)
            }
        } catch {
            return .failedUserMessage(L10n.premiumPurchaseFailed)
        }
    }

    enum RestoreResult: Equatable {
        case restoredPremium
        case nothingFound
        case failedUserMessage(String)
    }

    func restorePurchases() async -> RestoreResult {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if isPremium {
                return .restoredPremium
            }
            return .nothingFound
        } catch {
            return .failedUserMessage(L10n.premiumPurchaseFailed)
        }
    }

    private func listenForTransactionUpdates() async {
        for await verificationResult in Transaction.updates {
            do {
                let transaction = try Self.verify(verificationResult)
                guard transaction.productID == Self.premiumProductID else { continue }
                await transaction.finish()
                await refreshEntitlements()
            } catch {
                continue
            }
        }
    }

    private nonisolated static func verify(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .unverified:
            throw PurchaseVerificationError.unverified
        case .verified(let transaction):
            return transaction
        }
    }
}

private enum PurchaseVerificationError: Error {
    case unverified
}
