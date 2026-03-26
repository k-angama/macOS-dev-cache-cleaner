import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct CleanAllStorageCategoriesUseCaseTests {

    @Test func cleansCategoriesSequentially() async {
        let repository = DiskRepositoryMock()
        repository.totalDiskCapacity = 300
        repository.availableDiskCapacity = 100
        repository.setComputeResponses([1.0, 0], for: "Cache/A")
        repository.setComputeResponses([2.0, 0], for: "Cache/B")
        repository.setCleanFileDeletionSteps([1.0], for: "Cache/A")
        repository.setCleanFileDeletionSteps([2.0], for: "Cache/B")

        let cleanStorageCategoryUseCase = CleanStorageCategoryUseCase(diskRepository: repository)
        let cleanAllStorageCategoriesUseCase = CleanAllStorageCategoriesUseCase(
            cleanStorageCategoryUseCase: cleanStorageCategoryUseCase
        )

        let events = await collectEvents(
            from: cleanAllStorageCategoriesUseCase.execute(
                homeURL: testHomeURL,
                categories: [
                    makeCategory(name: "First", subcategories: [makeSubCategory(name: "Cache/A")]),
                    makeCategory(name: "Second", subcategories: [makeSubCategory(name: "Cache/B")])
                ]
            )
        )

        let finishedCategoryNames = events
            .filter { $0.phase == .finished }
            .map(\.categoryName)

        #expect(finishedCategoryNames == ["First", "Second"])
        #expect(repository.cleanedPaths == [
            repository.key(path: "Cache/A", match: ""),
            repository.key(path: "Cache/B", match: "")
        ])
    }
}
