//
//  SupportTipsManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation
import StoreKit


private enum SupportTipsError: LocalizedError {
    case failedVerification
    case productUnavailable
    case productsUnavailable

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "The App Store transaction could not be verified."
        case .productUnavailable:
            "The selected tip is currently unavailable."
        case .productsUnavailable:
            "Tip options are currently unavailable from the App Store."
        }
    }
}

protocol SupportTipsManaging {
    func loadProducts() async throws -> [SupportTipProductEntity]
    func purchase(productID: String) async throws -> SupportTipPurchaseResultEntity
}

class SupportTipsManager: SupportTipsManaging {

    private let productIDs = Constants.SupportTips.all
    private var productsByID: [String: Product] = [:]
    private var transactionUpdatesTask: Task<Void, Never>?
    
    init() {
        startObservingTransactions()
    }

    private func startObservingTransactions() {
        guard transactionUpdatesTask == nil else {
            return
        }

        transactionUpdatesTask = Task {
            await observeTransactions()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProducts() async throws -> [SupportTipProductEntity] {
        let products = try await fetchStoreProducts()
        productsByID = Dictionary(
            uniqueKeysWithValues: products.map { ($0.id, $0) }
        )

        return products.map { product in
            SupportTipProductEntity(
                id: product.id,
                title: product.displayName,
                message: product.description,
                displayPrice: product.displayPrice
            )
        }
    }

    func purchase(productID: String) async throws -> SupportTipPurchaseResultEntity {
        let product = try await resolveProduct(for: productID)
        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            let transaction = try verifiedTransaction(from: verificationResult)
            await transaction.finish()
            return .success
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    private func resolveProduct(for productID: String) async throws -> Product {
        if let product = productsByID[productID] {
            return product
        }

        let products = try await fetchStoreProducts()
        productsByID = Dictionary(
            uniqueKeysWithValues: products.map { ($0.id, $0) }
        )

        guard let product = productsByID[productID] else {
            throw SupportTipsError.productUnavailable
        }

        return product
    }

    private func fetchStoreProducts() async throws -> [Product] {
        let products = try await Product.products(
            for: productIDs
        )

        let sortedProducts = productIDs.compactMap { productID in
            products.first(where: { $0.id == productID })
        }

        guard sortedProducts.isEmpty == false else {
            throw SupportTipsError.productsUnavailable
        }

        return sortedProducts
    }

    private func observeTransactions() async {
        for await verificationResult in Transaction.updates {
            await finishIfNeeded(verificationResult)
        }
    }

    private func finishIfNeeded(
        _ verificationResult: VerificationResult<Transaction>
    ) async {
        guard
            let transaction = try? verifiedTransaction(from: verificationResult),
            productIDs.contains(transaction.productID)
        else {
            return
        }

        await transaction.finish()
    }

    private func verifiedTransaction(
        from verificationResult: VerificationResult<Transaction>
    ) throws -> Transaction {
        switch verificationResult {
        case .verified(let transaction):
            return transaction
        case .unverified(_, _):
            throw SupportTipsError.failedVerification
        }
    }
}

