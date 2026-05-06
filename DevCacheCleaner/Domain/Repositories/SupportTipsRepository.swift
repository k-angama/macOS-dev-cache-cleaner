//
//  SupportTipsRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

protocol SupportTipsRepository {
    func loadProducts() async throws -> [SupportTipProductEntity]
    func purchase(productID: String) async throws -> SupportTipPurchaseResultEntity
}
