//
//  SupportTipsRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct SupportTipsRepositoryImpl: SupportTipsRepository {
    private let manager: SupportTipsManaging

    init(manager: SupportTipsManaging) {
        self.manager = manager
    }

    func loadProducts() async throws -> [SupportTipProductEntity] {
        try await manager.loadProducts()
    }

    func purchase(productID: String) async throws -> SupportTipPurchaseResultEntity {
        try await manager.purchase(productID: productID)
    }
}
