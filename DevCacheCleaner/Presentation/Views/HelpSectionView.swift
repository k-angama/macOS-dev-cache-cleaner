//
//  HelpSectionView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct HelpSectionContent {
    let title: String
    let paragraphs: [String]
}

struct HelpSectionView: View {
    let section: HelpSectionContent
    let showsDivider: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.title3)
                .fontWeight(.bold)

            ForEach(section.paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }

            if showsDivider {
                Divider()
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    HelpSectionView(
        section: HelpSectionContent(
            title: "About DevCacheCleaner",
            paragraphs: [
                "DevCacheCleaner helps you quickly find and remove derived data, caches, and build artifacts to reclaim disk space.",
                "Use it to keep your development environment tidy and resolve build issues caused by stale artifacts."
            ]
        ),
        showsDivider: true
    )
}
