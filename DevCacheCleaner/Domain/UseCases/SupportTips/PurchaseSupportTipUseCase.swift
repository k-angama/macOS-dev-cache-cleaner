//
//  PurchaseSupportTipUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct PurchaseSupportTipUseCase {

    private let supportTipsRepository: SupportTipsRepository

    init(supportTipsRepository: SupportTipsRepository) {
        self.supportTipsRepository = supportTipsRepository
    }

    func execute(productID: String) async throws -> SupportTipPurchaseResultEntity {
        try await supportTipsRepository.purchase(productID: productID)
    }
}
