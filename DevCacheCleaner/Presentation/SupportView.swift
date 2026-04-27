//
//  SupportView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct SupportView: View {
    
    @State var viewModel: SupportViewModel

    private let tipOptions: [SupportTipOption] = [
        .init(
            title: "Coffee",
            price: "$1.99",
            message: "A small thank-you if DevCacheCleaner saved you a little space."
        ),
        .init(
            title: "Lunch",
            price: "$4.99",
            message: "A stronger show of support for ongoing updates and polish."
        ),
        .init(
            title: "Sponsor",
            price: "$9.99",
            message: "A generous tip if the app has become part of your developer workflow."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            Text("Choose a tip option")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(tipOptions) { option in
                    SupportTipCard(option: option)
                }
            }

            Divider()

            Text("Tip purchases will be wired with the App Store purchase flow next.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(width: 430)
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
    let container = AppContainer()
    SupportView(viewModel: container.supportViewModel)
}
