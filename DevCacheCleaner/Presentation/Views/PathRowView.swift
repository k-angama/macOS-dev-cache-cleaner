//
//  PathRowView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI

struct PathRowView: View {
    let subcategory: StorageSubCategoryEntity

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "folder.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(subcategory.path)
                    .font(.subheadline)
                    .textSelection(.enabled)

                if subcategory.match.isEmpty == false {
                    Text("Match prefix: \(subcategory.match)*")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            Text(subcategory.size.byteCountString)
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .padding(12)
        .background(Color.primary.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    PathRowView(
        subcategory: StorageSubCategoryEntity(
            path: "Library/Application Support/Code/User/workspaceStorage",
            match: "",
            size: 1_731_485_440
        )
    )
}
