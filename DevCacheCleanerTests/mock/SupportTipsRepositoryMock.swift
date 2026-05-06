import Foundation
@testable import DevCacheCleaner

final class SupportTipsRepositoryMock: SupportTipsRepository {

    var products: [SupportTipProductEntity] = []
    var purchaseResult: SupportTipPurchaseResultEntity = .success
    var loadError: Error?
    var purchaseError: Error?

    private(set) var loadCallCount = 0
    private(set) var purchaseCallCount = 0
    private(set) var purchasedProductID: String?

    func loadProducts() async throws -> [SupportTipProductEntity] {
        loadCallCount += 1

        if let loadError {
            throw loadError
        }

        return products
    }

    func purchase(productID: String) async throws -> SupportTipPurchaseResultEntity {
        purchaseCallCount += 1
        purchasedProductID = productID

        if let purchaseError {
            throw purchaseError
        }

        return purchaseResult
    }
}
