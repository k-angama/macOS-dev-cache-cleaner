//
//  SupportViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

@Observable
class SupportViewModel {
    var tipProducts: [SupportTipProductEntity] = []
    var isLoadingProducts: Bool = false
    var purchasingProductID: String?
    var footerMessage: String = "Tip purchases are processed securely through the App Store."
    var isAlertPresented: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""
    var isDismissScreen: Bool = false

    private let loadSupportTipProductsUseCase: LoadSupportTipProductsUseCase
    private let purchaseSupportTipUseCase: PurchaseSupportTipUseCase

    init(
        loadSupportTipProductsUseCase: LoadSupportTipProductsUseCase,
        purchaseSupportTipUseCase: PurchaseSupportTipUseCase
    ) {
        self.loadSupportTipProductsUseCase = loadSupportTipProductsUseCase
        self.purchaseSupportTipUseCase = purchaseSupportTipUseCase
    }

    func loadProductsIfNeeded() async {
        guard tipProducts.isEmpty, isLoadingProducts == false else {
            return
        }

        isLoadingProducts = true

        defer {
            isLoadingProducts = false
        }

        do {
            tipProducts = try await loadSupportTipProductsUseCase.execute()
            footerMessage = "Tips are processed securely through the App Store."
        } catch {
            footerMessage = "Tip options couldn't be loaded from the App Store."
            showAlert(
                title: "Unable to Load Tip Options",
                message: error.localizedDescription
            )
        }
    }

    func purchaseTip(productID: String) async {
        guard purchasingProductID == nil else {
            return
        }

        purchasingProductID = productID

        defer {
            purchasingProductID = nil
        }

        do {
            let purchaseResult = try await purchaseSupportTipUseCase.execute(
                productID: productID
            )

            let productTitle = tipProducts.first(where: { $0.id == productID })?.title
                ?? "support tip"

            switch purchaseResult {
            case .success:
                footerMessage = "Thanks for supporting DevCacheCleaner."
                showAlert(
                    title: "Thank You",
                    message: "Your \(productTitle) purchase helps support future updates.",
                    isDismiss: true
                )
            case .pending:
                footerMessage = "Your purchase is pending approval."
                showAlert(
                    title: "Purchase Pending",
                    message: "The App Store is still processing your \(productTitle.lowercased()) purchase.",
                )
            case .cancelled:
                break
            }
        } catch {
            footerMessage = "The purchase couldn't be completed."
            showAlert(
                title: "Purchase Failed",
                message: error.localizedDescription
            )
        }
    }

    private func showAlert(title: String, message: String, isDismiss: Bool = false) {
        alertTitle = title
        alertMessage = message
        isAlertPresented = true
        isDismissScreen = isDismiss
    }
}
