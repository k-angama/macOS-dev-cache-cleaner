//
//  SupportView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct SupportView: View {
    
    @State var viewModel: SupportViewModel
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            Text("Choose a tip option")
                .font(.headline)

            if viewModel.isLoadingProducts && viewModel.tipProducts.isEmpty {
                ProgressView("Loading tip options...")
                    .controlSize(.regular)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else if viewModel.tipProducts.isEmpty {
                Text("Tip options are currently unavailable.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.tipProducts) { option in
                        SupportTipCard(
                            option: option,
                            isDisabled: viewModel.purchasingProductID != nil,
                            isPurchasing: viewModel.purchasingProductID == option.id,
                            action: {
                                Task {
                                    await viewModel.purchaseTip(productID: option.id)
                                }
                            }
                        )
                    }
                }
            }

            Divider()

            Text(viewModel.footerMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(width: 430)
        .task {
            await viewModel.loadProductsIfNeeded()
        }
        .alert(
            viewModel.alertTitle,
            isPresented: $viewModel.isAlertPresented
        ) {
            Button("OK", role: .cancel) {
                guard viewModel.isDismissScreen else {
                    return
                }
                Task {
                    dismissWindow()
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image("DevCacheCleanerIcon")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Support DevCacheCleaner")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("If the app helps you free up disk space, you can support future updates with a small tip.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#Preview {
    AppContainer().supportDI.startPreview(products: [
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
    ])
}
