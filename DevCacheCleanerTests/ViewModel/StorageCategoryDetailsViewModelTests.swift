import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct StorageCategoryDetailsViewModelTests {

    @Test func init_buildsPathDerivedStateFromGroupedCategory() {
        let grouped = makeSubCategory(
            name: "VS Code",
            locations: [
                makeLocation(path: "Cache/A", size: 512),
                makeLocation(path: "Cache/B", size: 2_048),
                makeLocation(path: "Cache/Empty", size: 0),
            ]
        )
        let single = makeSubCategory(name: "Cache/C", size: 1_024)

        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(
                name: "IDE Caches",
                subcategories: [single, grouped]
            )
        )

        #expect(viewModel.pathCount == 4)
        #expect(viewModel.pathCountText == "4 items")
        #expect(viewModel.nonEmptyPathCount == 3)
        #expect(viewModel.sortedSubcategories.map(\.id) == [grouped.id, single.id])
        #expect(viewModel.largestPathSizeText == CGFloat(2_048).byteCountString)
        #expect(viewModel.selectedLocationIDs.isEmpty)
        #expect(viewModel.selectedSubcategories.isEmpty)
        #expect(viewModel.visibleRowCount == 2)
        #expect(viewModel.selectionSummary == "No path selected")
        #expect(viewModel.isDeleteSelectedDisabled)
    }

    @Test func locationSelection_buildsPartialSubcategoryPayload() throws {
        let first = makeLocation(path: "Cache/A", size: 1_024)
        let second = makeLocation(path: "Cache/B", size: 2_048)
        let grouped = makeSubCategory(name: "Cursor", locations: [first, second])
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(
                name: "IDE Caches",
                subcategories: [grouped]
            )
        )

        viewModel.updateSelection(locationID: first.id, isSelected: true)

        let selectedSubcategory = try #require(viewModel.selectedSubcategories.first)
        #expect(viewModel.isLocationSelected(first))
        #expect(viewModel.isLocationSelected(second) == false)
        #expect(viewModel.selectionState(for: grouped) == .partial)
        #expect(selectedSubcategory.id == grouped.id)
        #expect(selectedSubcategory.locations == [first])
        #expect(selectedSubcategory.size == 1_024)
        #expect(viewModel.selectionSummary == "1 selected - \(CGFloat(1_024).byteCountString)")
        #expect(viewModel.isDeleteSelectedDisabled == false)
    }

    @Test func parentSelection_selectsAndClearsEveryNonEmptyLocation() {
        let first = makeLocation(path: "Cache/A", size: 1_024)
        let second = makeLocation(path: "Cache/B", size: 2_048)
        let empty = makeLocation(path: "Cache/Empty", size: 0)
        let grouped = makeSubCategory(
            name: "VS Code",
            locations: [first, second, empty]
        )
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(name: "IDE Caches", subcategories: [grouped])
        )

        viewModel.toggleSelection(for: grouped)

        #expect(viewModel.selectionState(for: grouped) == .all)
        #expect(viewModel.selectedLocationIDs == [first.id, second.id])
        #expect(viewModel.selectedSize == 3_072)

        viewModel.toggleSelection(for: grouped)

        #expect(viewModel.selectionState(for: grouped) == .none)
        #expect(viewModel.selectedLocationIDs.isEmpty)
    }

    @Test func expansion_changesVisibleRowsForGroupedSubcategory() {
        let grouped = makeSubCategory(
            name: "VS Code",
            locations: [
                makeLocation(path: "Cache/A", size: 1),
                makeLocation(path: "Cache/B", size: 2),
            ]
        )
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(name: "IDE Caches", subcategories: [grouped])
        )

        viewModel.toggleExpansion(for: grouped.id)

        #expect(viewModel.isExpanded(grouped))
        #expect(viewModel.visibleRowCount == 3)

        viewModel.toggleExpansion(for: grouped.id)

        #expect(viewModel.isExpanded(grouped) == false)
        #expect(viewModel.visibleRowCount == 1)
    }

    @Test func updateCategory_preservesValidSelectionAndPrunesEmptyLocation() {
        let first = makeLocation(path: "Cache/A", size: 4_096)
        let second = makeLocation(path: "Cache/B", size: 2_048)
        let grouped = makeSubCategory(name: "Browser", locations: [first, second])
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(name: "Browser Caches", subcategories: [grouped])
        )
        viewModel.toggleSelection(for: grouped)

        let refreshedFirst = first.updateSize(0)
        let refreshedSecond = second.updateSize(1_024)
        viewModel.updateCategory(
            makeCategory(
                name: "Browser Caches",
                subcategories: [
                    grouped.updateLocations([refreshedFirst, refreshedSecond])
                ]
            )
        )

        #expect(viewModel.selectedLocationIDs == [second.id])
        #expect(viewModel.selectedSubcategories.first?.locations == [refreshedSecond])
        #expect(viewModel.selectedSize == 1_024)
        #expect(viewModel.selectionSummary == "1 selected - \(CGFloat(1_024).byteCountString)")
    }

    private func makeLocation(path: String, size: CGFloat) -> StorageLocationEntity {
        StorageLocationEntity(path: path, rule: .allContents, size: size)
    }
}
