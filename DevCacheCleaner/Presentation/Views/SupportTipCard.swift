//
//  SupportTipCard.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct SupportTipOption: Identifiable {
    let id = UUID()
    let title: String
    let price: String
    let message: String
}

struct SupportTipCard: View {
    let option: SupportTipOption

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(option.title)
                        .font(.headline)

                    Text(option.price)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(option.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 16)

            Button("Coming Soon") {}
                .buttonStyle(.borderedProminent)
                .disabled(true)
        }
        .padding(16)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    SupportTipCard(option: SupportTipOption(
        title: "Coffee",
        price: "$2.99",
        message: "Thanks for supporting development!"
    ))
}
