import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct SupportViewModelTests {

    @Test func loadProductsIfNeeded_updatesTipProducts() async {
        let context = makeSUT()
        context.repository.products = sampleProducts

        await context.viewModel.loadProductsIfNeeded()

        #expect(context.repository.loadCallCount == 1)
        #expect(context.viewModel.tipProducts == sampleProducts)
        #expect(context.viewModel.isLoadingProducts == false)
        #expect(
            context.viewModel.footerMessage ==
            "Tips are processed securely through the App Store."
        )
    }

    @Test func loadProductsIfNeeded_whenLoadingFails_showsAlert() async {
        let context = makeSUT()
        context.repository.loadError = TestSupportTipsError.productsUnavailable

        await context.viewModel.loadProductsIfNeeded()

        #expect(context.viewModel.tipProducts.isEmpty)
        #expect(context.viewModel.isAlertPresented)
        #expect(context.viewModel.alertTitle == "Unable to Load Tip Options")
        #expect(
            context.viewModel.alertMessage ==
            TestSupportTipsError.productsUnavailable.localizedDescription
        )
    }

    @Test func purchaseTip_whenSuccessful_showsThankYouMessage() async {
        let context = makeSUT()
        context.repository.products = sampleProducts
        context.repository.purchaseResult = .success
        context.viewModel.tipProducts = sampleProducts

        await context.viewModel.purchaseTip(productID: Constants.SupportTips.coffee)

        #expect(context.repository.purchaseCallCount == 1)
        #expect(context.repository.purchasedProductID == Constants.SupportTips.coffee)
        #expect(context.viewModel.purchasingProductID == nil)
        #expect(context.viewModel.isAlertPresented)
        #expect(context.viewModel.alertTitle == "Thank You")
        #expect(context.viewModel.footerMessage == "Thanks for supporting DevCacheCleaner.")
        #expect(context.viewModel.isDismissScreen)
    }

    @Test func purchaseTip_whenPending_showsPendingMessage() async {
        let context = makeSUT()
        context.repository.products = sampleProducts
        context.repository.purchaseResult = .pending
        context.viewModel.tipProducts = sampleProducts

        await context.viewModel.purchaseTip(productID: Constants.SupportTips.lunch)

        #expect(context.viewModel.isAlertPresented)
        #expect(context.viewModel.alertTitle == "Purchase Pending")
        #expect(context.viewModel.footerMessage == "Your purchase is pending approval.")
        #expect(context.viewModel.isDismissScreen == false)
    }

    @Test func purchaseTip_whenPurchaseFails_showsError() async {
        let context = makeSUT()
        context.repository.products = sampleProducts
        context.repository.purchaseError = TestSupportTipsError.purchaseFailed
        context.viewModel.tipProducts = sampleProducts

        await context.viewModel.purchaseTip(productID: Constants.SupportTips.sponsor)

        #expect(context.viewModel.isAlertPresented)
        #expect(context.viewModel.alertTitle == "Purchase Failed")
        #expect(
            context.viewModel.alertMessage ==
            TestSupportTipsError.purchaseFailed.localizedDescription
        )
        #expect(context.viewModel.footerMessage == "The purchase couldn't be completed.")
        #expect(context.viewModel.isDismissScreen == false)
    }

    private func makeSUT() -> SupportViewModelTestContext {
        let repository = SupportTipsRepositoryMock()
        let viewModel = SupportViewModel(
            loadSupportTipProductsUseCase: LoadSupportTipProductsUseCase(
                supportTipsRepository: repository
            ),
            purchaseSupportTipUseCase: PurchaseSupportTipUseCase(
                supportTipsRepository: repository
            )
        )

        return SupportViewModelTestContext(
            viewModel: viewModel,
            repository: repository
        )
    }
}

private let sampleProducts: [SupportTipProductEntity] = [
    .init(
        id: Constants.SupportTips.coffee,
        title: "Coffee Tip",
        message: "A small thank-you if DevCacheCleaner saved you a little space.",
        displayPrice: "$1.99"
    ),
    .init(
        id: Constants.SupportTips.lunch,
        title: "Lunch Tip",
        message: "A stronger show of support for ongoing updates and polish.",
        displayPrice: "$4.99"
    ),
    .init(
        id: Constants.SupportTips.sponsor,
        title: "Sponsor Tip",
        message: "A generous tip if the app has become part of your developer workflow.",
        displayPrice: "$9.99"
    )
]

private struct SupportViewModelTestContext {
    let viewModel: SupportViewModel
    let repository: SupportTipsRepositoryMock
}

private enum TestSupportTipsError: LocalizedError {
    case productsUnavailable
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .productsUnavailable:
            "Tip options are currently unavailable from the App Store."
        case .purchaseFailed:
            "The App Store couldn't complete the purchase."
        }
    }
}
