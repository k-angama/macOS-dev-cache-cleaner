import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct StorageCategoryDetailsViewModelTests {

    @Test func init_buildsDerivedStateFromCategory() {
        let category = makeCategory(
            name: "IDE Caches",
            subcategories: [
                makeSubCategory(name: "small", size: 512),
                makeSubCategory(
                    name: "prefix",
                    rule: .childNamePrefix("AndroidStudio"),
                    size: 2_048
                ),
                makeSubCategory(name: "empty", size: 0)
            ]
        )

        let viewModel = StorageCategoryDetailsViewModel(category: category)

        #expect(viewModel.pathCount == 3)
        #expect(viewModel.pathCountText == "3 items")
        #expect(viewModel.nonEmptyPathCount == 2)
        #expect(viewModel.sortedSubcategories.map(\.path) == ["prefix", "small", "empty"])
        #expect(viewModel.largestPathSizeText == CGFloat(2_048).byteCountString)
        #expect(viewModel.selectedSubcategoryIDs.isEmpty)
        #expect(viewModel.selectedSubcategories.isEmpty)
        #expect(viewModel.selectedSize == 0)
        #expect(viewModel.selectionSummary == "No path selected")
        #expect(viewModel.isDeleteSelectedDisabled)
    }

    @Test func updateSelection_updatesSelectedStateAndSummary() {
        let firstSubcategory = makeSubCategory(name: "first", size: 1_024)
        let secondSubcategory = makeSubCategory(name: "second", size: 2_048)
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(
                name: "Xcode Caches",
                subcategories: [firstSubcategory, secondSubcategory]
            )
        )

        viewModel.updateSelection(subcategoryID: firstSubcategory.id, isSelected: true)

        #expect(viewModel.isSelected(firstSubcategory))
        #expect(viewModel.isSelected(secondSubcategory) == false)
        #expect(viewModel.selectedSubcategories == [firstSubcategory])
        #expect(viewModel.selectedSize == 1_024)
        #expect(viewModel.selectionSummary == "1 selected - \(CGFloat(1_024).byteCountString)")
        #expect(viewModel.isDeleteSelectedDisabled == false)

        viewModel.updateSelection(subcategoryID: firstSubcategory.id, isSelected: false)

        #expect(viewModel.selectedSubcategoryIDs.isEmpty)
        #expect(viewModel.selectedSubcategories.isEmpty)
        #expect(viewModel.selectionSummary == "No path selected")
        #expect(viewModel.isDeleteSelectedDisabled)
    }

    @Test func updateCategory_prunesSelectionForEmptySubcategories() {
        let selectedSubcategory = makeSubCategory(name: "selected", size: 4_096)
        let keptSubcategory = makeSubCategory(name: "kept", size: 2_048)
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(
                name: "Workspace Caches",
                subcategories: [selectedSubcategory, keptSubcategory]
            )
        )
        viewModel.updateSelection(subcategoryID: selectedSubcategory.id, isSelected: true)

        let cleanedSelectedSubcategory = selectedSubcategory.updateSize(size: 0)
        viewModel.updateCategory(
            makeCategory(
                name: "Workspace Caches",
                subcategories: [cleanedSelectedSubcategory, keptSubcategory]
            )
        )

        #expect(viewModel.isSelected(cleanedSelectedSubcategory) == false)
        #expect(viewModel.selectedSubcategoryIDs.isEmpty)
        #expect(viewModel.selectedSubcategories.isEmpty)
        #expect(viewModel.nonEmptyPathCount == 1)
        #expect(viewModel.selectionSummary == "No path selected")
        #expect(viewModel.isDeleteSelectedDisabled)
    }

    @Test func updateCategory_preservesSelectionForStillSelectableSubcategories() {
        let selectedSubcategory = makeSubCategory(name: "selected", size: 4_096)
        let viewModel = StorageCategoryDetailsViewModel(
            category: makeCategory(
                name: "Browser Caches",
                subcategories: [selectedSubcategory]
            )
        )
        viewModel.updateSelection(subcategoryID: selectedSubcategory.id, isSelected: true)

        let refreshedSelectedSubcategory = selectedSubcategory.updateSize(size: 2_048)
        viewModel.updateCategory(
            makeCategory(
                name: "Browser Caches",
                subcategories: [refreshedSelectedSubcategory]
            )
        )

        #expect(viewModel.isSelected(refreshedSelectedSubcategory))
        #expect(viewModel.selectedSubcategories == [refreshedSelectedSubcategory])
        #expect(viewModel.selectedSize == 2_048)
        #expect(viewModel.selectionSummary == "1 selected - \(CGFloat(2_048).byteCountString)")
        #expect(viewModel.isDeleteSelectedDisabled == false)
    }
}
