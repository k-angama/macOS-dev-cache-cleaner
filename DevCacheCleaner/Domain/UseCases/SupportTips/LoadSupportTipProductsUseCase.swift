//
//  LoadSupportTipProductsUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct LoadSupportTipProductsUseCase {

    private let supportTipsRepository: SupportTipsRepository

    init(supportTipsRepository: SupportTipsRepository) {
        self.supportTipsRepository = supportTipsRepository
    }

    func execute() async throws -> [SupportTipProductEntity] {
        try await supportTipsRepository.loadProducts()
    }
}
