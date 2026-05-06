//
//  StorageCategoryDetailsView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI

struct StorageCategoryDetailsView: View {
    static let panelWidth: CGFloat = 420

    let category: StorageCategoryEntity
    let onCleanSelected: (([StorageSubCategoryEntity]) -> Void)?
    @State private var selectedSubcategoryIDs: Set<UUID> = []

    init(
        category: StorageCategoryEntity,
        onCleanSelected: (([StorageSubCategoryEntity]) -> Void)? = nil
    ) {
        self.category = category
        self.onCleanSelected = onCleanSelected
    }

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
        .onChange(of: category) { _, newCategory in
            pruneSelection(for: newCategory)
        }
    }

    private var sortedSubcategories: [StorageSubCategoryEntity] {
        category.categories.sorted { $0.size > $1.size }
    }

    private var nonEmptyPathCount: Int {
        category.categories.filter { $0.size > 0.01 }.count
    }

    private var selectedSubcategories: [StorageSubCategoryEntity] {
        sortedSubcategories.filter { selectedSubcategoryIDs.contains($0.id) }
    }

    private var selectedSize: CGFloat {
        selectedSubcategories.reduce(0) { $0 + $1.size }
    }

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(category.color.gradient)
                .frame(width: 12, height: 12)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 8) {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(category.size.byteCountString)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding(14)
        .background(category.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var summarySection: some View {
        HStack(spacing: 8) {
            SummaryCard(
                title: "Paths",
                value: "\(category.categories.count)",
                symbolName: "folder"
            )
            SummaryCard(
                title: "Non-empty",
                value: "\(nonEmptyPathCount)",
                symbolName: "externaldrive.fill.badge.checkmark"
            )
            SummaryCard(
                title: "Largest path",
                value: sortedSubcategories.first?.size.byteCountString ?? "0 KB",
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
                Text("\(category.categories.count) item\(category.categories.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if sortedSubcategories.isEmpty {
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
                        ForEach(sortedSubcategories) { subcategory in
                            PathRowView(
                                subcategory: subcategory,
                                isSelected: selectedSubcategoryIDs.contains(subcategory.id),
                                onSelectionChange: { isSelected in
                                    updateSelection(
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
                        Text(selectionSummary)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button(role: .destructive) {
                            onCleanSelected?(selectedSubcategories)
                        } label: {
                            Label("Delete Selected", systemImage: "trash")
                        }
                        .disabled(selectedSubcategoryIDs.isEmpty)
                        .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var selectionSummary: String {
        guard selectedSubcategoryIDs.isEmpty == false else {
            return "No path selected"
        }

        return "\(selectedSubcategoryIDs.count) selected - \(selectedSize.byteCountString)"
    }

    private func updateSelection(subcategoryID: UUID, isSelected: Bool) {
        if isSelected {
            selectedSubcategoryIDs.insert(subcategoryID)
        } else {
            selectedSubcategoryIDs.remove(subcategoryID)
        }
    }

    private func pruneSelection(for category: StorageCategoryEntity) {
        let selectableIDs = Set(
            category.categories
                .filter { $0.size > 0.01 }
                .map(\.id)
        )
        selectedSubcategoryIDs.formIntersection(selectableIDs)
    }
}

#Preview("Storage Category Details") {
    return StorageCategoryDetailsView(
        category: .detailsPreview
    )
        .padding()
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
