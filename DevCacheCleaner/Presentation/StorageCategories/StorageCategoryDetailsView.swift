//
//  StorageCategoryDetailsView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI

struct StorageCategoryDetailsView: View {
    static let panelWidth: CGFloat = 460

    let onCleanSelected: (([StorageSubCategoryEntity]) -> Void)?
    @State var viewModel: StorageCategoryDetailsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerCard
            summarySection
            pathsSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: Self.panelWidth, alignment: .topLeading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(viewModel.category.color.gradient)
                .frame(width: 12, height: 12)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.category.size.byteCountString)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding(14)
        .background(viewModel.category.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var summarySection: some View {
        HStack(spacing: 8) {
            SummaryCard(
                title: "Paths",
                value: "\(viewModel.pathCount)",
                symbolName: "folder"
            )
            SummaryCard(
                title: "Non-empty",
                value: "\(viewModel.nonEmptyPathCount)",
                symbolName: "externaldrive.fill.badge.checkmark"
            )
            SummaryCard(
                title: "Largest path",
                value: viewModel.largestPathSizeText,
                symbolName: "chart.bar.fill"
            )
        }
    }

    private var pathsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Included Paths")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(viewModel.pathCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.sortedSubcategories.isEmpty {
                Text("No paths available for this category.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.sortedSubcategories) { subcategory in
                            PathRowView(
                                subcategory: subcategory,
                                isSelected: viewModel.isSelected(subcategory),
                                onSelectionChange: { isSelected in
                                    viewModel.updateSelection(
                                        subcategoryID: subcategory.id,
                                        isSelected: isSelected
                                    )
                                }
                            )
                        }
                    }
                }.frame(maxHeight: 500)

                if onCleanSelected != nil {
                    Divider()

                    HStack(spacing: 10) {
                        Text(viewModel.selectionSummary)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button(role: .destructive) {
                            onCleanSelected?(viewModel.selectedSubcategories)
                        } label: {
                            Label("Delete Selected", systemImage: "trash")
                        }
                        .disabled(viewModel.isDeleteSelectedDisabled)
                        .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview("Storage Category Details") {
    StorageCategoryDetailsDI().start(data: (
        category: .detailsPreview, onCleanSelected: {_ in })
    ).padding()
}

private extension StorageCategoryEntity {
    static var detailsPreview: StorageCategoryEntity {
        StorageCategoryEntity(
            name: "IDE (JetBrains, VSCode) Caches",
            color: .green,
            size: 4_711_485_440,
            categories: [
                StorageSubCategoryEntity(
                    path: "Library/Application Support/Code/User/workspaceStorage",
                    rule: .allContents,
                    size: 1_731_485_440
                ),
                StorageSubCategoryEntity(
                    path: "Library/Application Support/Code/CachedData",
                    rule: .allContents,
                    size: 1_280_000_000
                ),
                StorageSubCategoryEntity(
                    path: "Library/Application Support/Code/Cache",
                    rule: .allContents,
                    size: 845_000_000
                ),
                StorageSubCategoryEntity(
                    path: "Library/Caches/JetBrains",
                    rule: .childNamePrefix("AndroidStudio"),
                    size: 615_000_000
                ),
                StorageSubCategoryEntity(
                    path: "Library/Caches/CocoaPods",
                    rule: .allContents,
                    size: 240_000_000
                )
            ]
        )
    }
}
