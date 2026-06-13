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
                label: groupSelectionLabel,
                hint: "Selects or clears every non-empty path for this tool.",
                action: { onToggleSelection?() }
            )

            Button(action: { onToggleExpansion?() }) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 14)
            }
            .buttonStyle(.plain)
            .help(isExpanded ? "Collapse paths" : "Expand paths")
            .accessibilityLabel(
                "\(isExpanded ? "Collapse" : "Expand") \(subcategory.name ?? "grouped paths")"
            )
            .accessibilityHint("Shows or hides the individual cache paths.")

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
                .accessibilityLabel("Total size")
                .accessibilityValue(subcategory.size.byteCountString)
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
                label: locationSelectionLabel(location),
                hint: isLocationSelectable(location)
                    ? "Includes or excludes this path from selective cleanup."
                    : "This path is empty and cannot be selected.",
                action: {
                    onLocationSelectionChange?(
                        location.id,
                        isLocationSelected(location) == false
                    )
                }
            )

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
                    .accessibilityLabel("Cache path")
                    .accessibilityValue(location.path)

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
                .accessibilityLabel("Path size")
                .accessibilityValue(location.size.byteCountString)
        }
        .padding(.vertical, isNested ? 4 : 0)
        .padding(.leading, isNested ? 26 : 0)
    }

    private func selectionButton(
        state: StorageCategoryDetailsViewModel.SelectionState,
        isEnabled: Bool,
        label: String,
        hint: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: selectionSymbol(for: state))
                .foregroundStyle(isEnabled ? Color.primary : .secondary)
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .help(label)
        .accessibilityLabel(label)
        .accessibilityValue(selectionDescription(for: state))
        .accessibilityHint(hint)
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

    private var groupSelectionLabel: String {
        let name = subcategory.name ?? "grouped paths"
        return selectionState == .all
            ? "Clear all \(name) paths"
            : "Select all \(name) paths"
    }

    private func locationSelectionLabel(_ location: StorageLocationEntity) -> String {
        isLocationSelected(location)
            ? "Deselect \(location.path)"
            : "Select \(location.path)"
    }

    private func selectionDescription(for state: StorageCategoryDetailsViewModel.SelectionState) -> String {
        switch state {
        case .none:
            return "Not selected"
        case .partial:
            return "Partially selected"
        case .all:
            return "Selected"
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
