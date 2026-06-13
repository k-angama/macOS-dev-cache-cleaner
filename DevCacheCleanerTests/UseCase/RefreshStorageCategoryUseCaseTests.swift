import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct RefreshStorageCategoryUseCaseTests {

    @Test func updatesEachSubcategorySize() async {
        let repository = DiskRepositoryMock()
        repository.setComputeResponses([1.25], for: "Library/Caches/A")
        repository.setComputeResponses([2.75], for: "Library/Caches/B", rule: .childNamePrefix("match"))

        let category = makeCategory(
            name: "Caches",
            subcategories: [
                makeSubCategory(name: "Library/Caches/A"),
                makeSubCategory(name: "Library/Caches/B", rule: .childNamePrefix("match"))
            ]
        )

        let updatedCategory = await RefreshStorageCategoryUseCase(diskRepository: repository).execute(
            homeURL: testHomeURL,
            category: category
        )

        #expect(abs(updatedCategory.categories[0].size - 1.25) < 0.0001)
        #expect(abs(updatedCategory.categories[1].size - 2.75) < 0.0001)
        #expect(abs(updatedCategory.size - 4.0) < 0.0001)
    }

    @Test func sumsSizesAcrossSubcategoryLocations() async {
        let repository = DiskRepositoryMock()
        repository.setComputeResponses([1.25], for: "Cache/A")
        repository.setComputeResponses(
            [2.75],
            for: "Cache/B",
            rule: .childNamePrefix("match")
        )
        let category = makeCategory(
            name: "Grouped",
            subcategories: [
                makeSubCategory(
                    name: "Tool",
                    locations: [
                        StorageLocationEntity(
                            path: "Cache/A",
                            rule: .allContents,
                            size: 0
                        ),
                        StorageLocationEntity(
                            path: "Cache/B",
                            rule: .childNamePrefix("match"),
                            size: 0
                        ),
                    ]
                )
            ]
        )

        let updatedCategory = await RefreshStorageCategoryUseCase(
            diskRepository: repository
        ).execute(homeURL: testHomeURL, category: category)

        #expect(updatedCategory.categories.count == 1)
        #expect(updatedCategory.categories[0].locations.map(\.size) == [1.25, 2.75])
        #expect(updatedCategory.categories[0].size == 4)
        #expect(updatedCategory.size == 4)
    }
}
