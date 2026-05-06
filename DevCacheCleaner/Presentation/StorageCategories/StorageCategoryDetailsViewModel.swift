//
//  StorageCategoryDetailsViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

@Observable
class StorageCategoryDetailsViewModel {
    private(set) var selectedSubcategoryIDs: Set<UUID> = []

    var sortedSubcategories: [StorageSubCategoryEntity] = []
    var pathCount: Int = 0
    var pathCountText: String = "0 items"
    var nonEmptyPathCount: Int = 0
    var largestPathSizeText: String = "0 KB"
    var selectedSubcategories: [StorageSubCategoryEntity] = []
    var selectedSize: CGFloat = 0
    var selectionSummary: String = "No path selected"
    var isDeleteSelectedDisabled: Bool = true
    var category: StorageCategoryEntity

    init(category: StorageCategoryEntity) {
        self.category = category
        updateCategory(category)
    }

    func updateCategory(_ category: StorageCategoryEntity) {
        self.category = category
        sortedSubcategories = category.categories.sorted { $0.size > $1.size }
        pathCount = category.categories.count
        pathCountText = "\(pathCount) item\(pathCount == 1 ? "" : "s")"
        nonEmptyPathCount = category.categories.filter { isSubcategorySelectable($0) }.count
        largestPathSizeText = sortedSubcategories.first?.size.byteCountString ?? "0 KB"
        pruneSelection(for: category)
        updateSelectionState()
    }

    func isSelected(_ subcategory: StorageSubCategoryEntity) -> Bool {
        selectedSubcategoryIDs.contains(subcategory.id)
    }

    func isSubcategorySelectable(_ subcategory: StorageSubCategoryEntity) -> Bool {
        subcategory.size > 0.01
    }

    func updateSelection(subcategoryID: UUID, isSelected: Bool) {
        if isSelected {
            selectedSubcategoryIDs.insert(subcategoryID)
        } else {
            selectedSubcategoryIDs.remove(subcategoryID)
        }

        updateSelectionState()
    }

    private func pruneSelection(for category: StorageCategoryEntity) {
        let selectableIDs = Set(
            category.categories
                .filter { isSubcategorySelectable($0) }
                .map(\.id)
        )
        selectedSubcategoryIDs.formIntersection(selectableIDs)
    }

    private func updateSelectionState() {
        selectedSubcategories = sortedSubcategories.filter {
            selectedSubcategoryIDs.contains($0.id)
        }
        selectedSize = selectedSubcategories.reduce(0) { $0 + $1.size }
        isDeleteSelectedDisabled = selectedSubcategoryIDs.isEmpty

        guard selectedSubcategoryIDs.isEmpty == false else {
            selectionSummary = "No path selected"
            return
        }

        selectionSummary = "\(selectedSubcategoryIDs.count) selected - \(selectedSize.byteCountString)"
    }
}
