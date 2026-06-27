//
//  StorageCategoryDetailsViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

@Observable
class StorageCategoryDetailsViewModel {
    enum SelectionState {
        case none
        case partial
        case all
    }

    private(set) var selectedLocationIDs: Set<UUID> = []
    private(set) var expandedSubcategoryIDs: Set<UUID> = []

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
        let locations = category.categories.flatMap(\.locations)
        pathCount = locations.count
        pathCountText = "\(pathCount) item\(pathCount == 1 ? "" : "s")"
        nonEmptyPathCount = locations.filter { isLocationSelectable($0) }.count
        largestPathSizeText = locations.max { $0.size < $1.size }?
            .size.byteCountString ?? "0 KB"
        pruneSelection(for: category)
        pruneExpansion(for: category)
        updateSelectionState()
    }

    var visibleRowCount: Int {
        sortedSubcategories.reduce(0) { count, subcategory in
            guard subcategory.locations.count > 1 else {
                return count + 1
            }

            return count + 1 + (
                expandedSubcategoryIDs.contains(subcategory.id)
                ? subcategory.locations.count
                : 0
            )
        }
    }

    func isExpanded(_ subcategory: StorageSubCategoryEntity) -> Bool {
        expandedSubcategoryIDs.contains(subcategory.id)
    }

    func toggleExpansion(for subcategoryID: UUID) {
        if expandedSubcategoryIDs.contains(subcategoryID) {
            expandedSubcategoryIDs.remove(subcategoryID)
        } else {
            expandedSubcategoryIDs.insert(subcategoryID)
        }
    }

    func isLocationSelected(_ location: StorageLocationEntity) -> Bool {
        selectedLocationIDs.contains(location.id)
    }

    func isLocationSelectable(_ location: StorageLocationEntity) -> Bool {
        location.size > 0.01
    }

    func selectionState(for subcategory: StorageSubCategoryEntity) -> SelectionState {
        let selectableLocations = subcategory.locations.filter(isLocationSelectable)
        let selectedCount = selectableLocations.filter(isLocationSelected).count

        guard selectedCount > 0 else {
            return .none
        }

        return selectedCount == selectableLocations.count ? .all : .partial
    }

    func updateSelection(locationID: UUID, isSelected: Bool) {
        if isSelected {
            selectedLocationIDs.insert(locationID)
        } else {
            selectedLocationIDs.remove(locationID)
        }

        updateSelectionState()
    }

    func toggleSelection(for subcategory: StorageSubCategoryEntity) {
        let selectableIDs = Set(
            subcategory.locations
                .filter(isLocationSelectable)
                .map(\.id)
        )

        if selectionState(for: subcategory) == .all {
            selectedLocationIDs.subtract(selectableIDs)
        } else {
            selectedLocationIDs.formUnion(selectableIDs)
        }

        updateSelectionState()
    }

    private func pruneSelection(for category: StorageCategoryEntity) {
        let selectableIDs = Set(
            category.categories
                .flatMap(\.locations)
                .filter(isLocationSelectable)
                .map(\.id)
        )
        selectedLocationIDs.formIntersection(selectableIDs)
    }

    private func pruneExpansion(for category: StorageCategoryEntity) {
        let expandableIDs = Set(
            category.categories
                .filter { $0.locations.count > 1 }
                .map(\.id)
        )
        expandedSubcategoryIDs.formIntersection(expandableIDs)
    }

    private func updateSelectionState() {
        selectedSubcategories = sortedSubcategories.compactMap { subcategory in
            let selectedLocations = subcategory.locations.filter(isLocationSelected)
            guard selectedLocations.isEmpty == false else {
                return nil
            }

            return subcategory.updateLocations(selectedLocations)
        }
        selectedSize = selectedSubcategories.reduce(0) { $0 + $1.size }
        isDeleteSelectedDisabled = selectedLocationIDs.isEmpty

        guard selectedLocationIDs.isEmpty == false else {
            selectionSummary = "No path selected"
            return
        }

        selectionSummary = "\(selectedLocationIDs.count) selected - \(selectedSize.byteCountString)"
    }
}
