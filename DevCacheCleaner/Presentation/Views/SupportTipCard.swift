//
//  SupportTipCard.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct SupportTipCard: View {
    let option: SupportTipProductEntity
    let isDisabled: Bool
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(option.title)
                        .font(.headline)

                    Text(option.displayPrice)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(option.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 16)

            Button(isPurchasing ? "Processing..." : "Support") {
                action()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isDisabled)
        }
        .padding(16)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    SupportTipCard(
        option: SupportTipProductEntity(
            id: Constants.SupportTips.coffee,
            title: "Coffee Tip",
            message: "A small thank-you if DevCacheCleaner saved you a little space.",
            displayPrice: "$1.99"
        ),
        isDisabled: false,
        isPurchasing: false,
        action: {}
    )
}
