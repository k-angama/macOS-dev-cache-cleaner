import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct RefreshStorageCategoryUseCaseTests {

    @Test func updatesEachSubcategorySize() async {
        let repository = DiskRepositoryMock()
        repository.setComputeResponses([1.25], for: "Library/Caches/A")
        repository.setComputeResponses([2.75], for: "Library/Caches/B", match: "match")

        let category = makeCategory(
            name: "Caches",
            subcategories: [
                makeSubCategory(name: "Library/Caches/A"),
                makeSubCategory(name: "Library/Caches/B", match: "match")
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
}
