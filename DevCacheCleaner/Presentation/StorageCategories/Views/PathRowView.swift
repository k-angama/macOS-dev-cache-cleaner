//
//  PathRowView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI

struct PathRowView: View {
    let subcategory: StorageSubCategoryEntity
    var isSelected: Bool = false
    var onSelectionChange: ((Bool) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if onSelectionChange != nil {
                Toggle(
                    isOn: Binding(
                        get: {
                            isSelected
                        },
                        set: { newValue in
                            onSelectionChange?(newValue)
                        }
                    )
                ) {
                    EmptyView()
                }
                .toggleStyle(.checkbox)
                .disabled(subcategory.size <= 0.01)
            }

            Image(systemName: "folder.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(subcategory.path)
                    .font(.subheadline)
                    .textSelection(.enabled)

                if case .childNamePrefix = subcategory.rule {
                    Text(subcategory.rule.displayDescription)
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
            rule: .allContents,
            size: 1_731_485_440
        )
    )
}
