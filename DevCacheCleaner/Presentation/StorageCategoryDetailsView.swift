//
//  StorageCategoryDetailsView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI

struct StorageCategoryDetailsView: View {

    @State var viewModel: StorageCategoryDetailsViewModel

    var body: some View {
        Group {
            if let category = viewModel.selectedCategory {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerCard(category)
                        summarySection(category)
                        pathsSection(category)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minWidth: 460, idealWidth: 600, minHeight: 480)
                .background(Color(nsColor: .windowBackgroundColor))
            } else {
                ContentUnavailableView(
                    "No Category Selected",
                    systemImage: "sidebar.right",
                    description: Text("Select a category from the main window to inspect its paths.")
                )
                .frame(minWidth: 480, minHeight: 360)
            }
        }
        .background(
            WindowReaderView { window in
                viewModel.registerDetailsWindow(window)
            }
        )
    }

    private func headerCard(_ category: StorageCategoryEntity) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(category.color.gradient)
                .frame(width: 18, height: 18)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(category.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(category.size.byteCountString)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func summarySection(_ category: StorageCategoryEntity) -> some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Paths",
                value: "\(category.categories.count)",
                symbolName: "folder"
            )
            SummaryCard(
                title: "Non-empty",
                value: "\(viewModel.nonEmptyPathCount)",
                symbolName: "externaldrive.fill.badge.checkmark"
            )
            SummaryCard(
                title: "Largest path",
                value: viewModel.sortedSubcategories.first?.size.byteCountString ?? "0 KB",
                symbolName: "chart.bar.fill"
            )
        }
    }

    private func pathsSection(_ category: StorageCategoryEntity) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Included Paths")
                    .font(.headline)
                Spacer()
                Text("\(category.categories.count) item\(category.categories.count == 1 ? "" : "s")")
                    .font(.footnote)
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
                VStack(spacing: 10) {
                    ForEach(viewModel.sortedSubcategories) { subcategory in
                        PathRowView(subcategory: subcategory)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview("Storage Category Details") {
    let store = StorageCategoryDetailsStore()
    store.show(category: .detailsPreview)
    return StorageCategoryDetailsView(
        viewModel: StorageCategoryDetailsViewModel(store: store)
    )
        .padding()
}

#Preview("Empty Storage Category") {
    StorageCategoryDetailsView(
        viewModel: StorageCategoryDetailsViewModel(store: StorageCategoryDetailsStore())
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
                    match: "",
                    size: 1_731_485_440
                ),
                StorageSubCategoryEntity(
                    path: "Library/Application Support/Code/CachedData",
                    match: "",
                    size: 1_280_000_000
                ),
                StorageSubCategoryEntity(
                    path: "Library/Application Support/Code/Cache",
                    match: "",
                    size: 845_000_000
                ),
                StorageSubCategoryEntity(
                    path: "Library/Caches/JetBrains",
                    match: "AndroidStudio",
                    size: 615_000_000
                ),
                StorageSubCategoryEntity(
                    path: "Library/Caches/CocoaPods",
                    match: "",
                    size: 240_000_000
                )
            ]
        )
    }
}
