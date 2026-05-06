//
//  SupportDI.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

final class SupportDI: PresentationDI {
    private let supportTipsManager: SupportTipsManaging

    init(supportTipsManager: SupportTipsManaging) {
        self.supportTipsManager = supportTipsManager
    }

    func start(data: Void) -> SupportView {
        SupportView(viewModel: viewModel)
    }

    lazy var viewModel: SupportViewModel = {
        let supportTipsRepository = SupportTipsRepositoryImpl(
            manager: supportTipsManager
        )
        let loadSupportTipProductsUseCase = LoadSupportTipProductsUseCase(
            supportTipsRepository: supportTipsRepository
        )
        let purchaseSupportTipUseCase = PurchaseSupportTipUseCase(
            supportTipsRepository: supportTipsRepository
        )
        return SupportViewModel(
            loadSupportTipProductsUseCase: loadSupportTipProductsUseCase,
            purchaseSupportTipUseCase: purchaseSupportTipUseCase
        )
    }()
}


#if DEBUG
extension SupportDI {
    func startPreview(products: [SupportTipProductEntity]) -> SupportView {
        viewModel.tipProducts = products
        return start()
    }
}
#endif
