import Testing
@testable import DevCacheCleaner

struct SupportTipsUseCaseTests {

    @Test func loadSupportTipProducts_returnsRepositoryProducts() async throws {
        let repository = SupportTipsRepositoryMock()
        repository.products = [
            .init(
                id: Constants.SupportTips.coffee,
                title: "Coffee Tip",
                message: "A small thank-you.",
                displayPrice: "$1.99"
            )
        ]

        let useCase = LoadSupportTipProductsUseCase(
            supportTipsRepository: repository
        )

        let products = try await useCase.execute()

        #expect(repository.loadCallCount == 1)
        #expect(products == repository.products)
    }

    @Test func purchaseSupportTip_forwardsProductIDAndResult() async throws {
        let repository = SupportTipsRepositoryMock()
        repository.purchaseResult = .pending

        let useCase = PurchaseSupportTipUseCase(
            supportTipsRepository: repository
        )

        let result = try await useCase.execute(
            productID: Constants.SupportTips.sponsor
        )

        #expect(repository.purchaseCallCount == 1)
        #expect(repository.purchasedProductID == Constants.SupportTips.sponsor)
        #expect(result == .pending)
    }
}
