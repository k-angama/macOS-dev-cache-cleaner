//
//  PathRowView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI

struct PathRowView: View {
    let subcategory: StorageSubCategoryEntity
    let selectionState: StorageCategoryDetailsViewModel.SelectionState
    let isExpanded: Bool
    let isLocationSelected: (StorageLocationEntity) -> Bool
    let isLocationSelectable: (StorageLocationEntity) -> Bool
    var onToggleExpansion: (() -> Void)?
    var onToggleSelection: (() -> Void)?
    var onLocationSelectionChange: ((UUID, Bool) -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            if subcategory.locations.count > 1 {
                groupHeader

                if isExpanded {
                    ForEach(subcategory.locations) { location in
                        locationRow(location, isNested: true)
                    }
                }
            } else if let location = subcategory.locations.first {
                locationRow(location, isNested: false)
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var groupHeader: some View {
        HStack(spacing: 10) {
            selectionButton(
                state: selectionState,
                isEnabled: subcategory.locations.contains(where: isLocationSelectable),
                action: { onToggleSelection?() }
            )

            Button(action: { onToggleExpansion?() }) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 14)
            }
            .buttonStyle(.plain)

            Image(systemName: "folder.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(subcategory.name ?? "Grouped Paths")
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer(minLength: 12)

            Text(subcategory.size.byteCountString)
                .font(.footnote)
                .fontWeight(.semibold)
        }
    }

    private func locationRow(
        _ location: StorageLocationEntity,
        isNested: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            selectionButton(
                state: isLocationSelected(location) ? .all : .none,
                isEnabled: isLocationSelectable(location),
                action: {
                    onLocationSelectionChange?(
                        location.id,
                        isLocationSelected(location) == false
                    )
                }
            )

            if isNested {
                Color.clear.frame(width: 14, height: 1)
            }

            Image(systemName: "folder")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                if isNested == false, let name = subcategory.name {
                    Text(name)
                        .font(.caption2)
                        .fontWeight(.medium)
                }

                Text(location.path)
                    .font(.subheadline)
                    .textSelection(.enabled)

                if case .childNamePrefix = location.rule {
                    Text(location.rule.displayDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            Text(location.size.byteCountString)
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .padding(.vertical, isNested ? 4 : 0)
    }

    private func selectionButton(
        state: StorageCategoryDetailsViewModel.SelectionState,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: selectionSymbol(for: state))
                .foregroundStyle(isEnabled ? Color.accentColor : .secondary)
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
    }

    private func selectionSymbol(
        for state: StorageCategoryDetailsViewModel.SelectionState
    ) -> String {
        switch state {
        case .none:
            return "square"
        case .partial:
            return "minus.square.fill"
        case .all:
            return "checkmark.square.fill"
        }
    }
}

#Preview {
    PathRowView(
        subcategory: StorageSubCategoryEntity(
            name: "VS Code",
            locations: [
                StorageLocationEntity(
                    path: "Library/Application Support/Code/User/workspaceStorage",
                    rule: .allContents,
                    size: 1_731_485_440
                ),
                StorageLocationEntity(
                    path: "Library/Application Support/Code/Cache",
                    rule: .allContents,
                    size: 845_000_000
                )
            ],
            size: 2_576_485_440
        ),
        selectionState: .partial,
        isExpanded: true,
        isLocationSelected: { $0.path.contains("workspaceStorage") },
        isLocationSelectable: { $0.size > 0.01 }
    )
}
