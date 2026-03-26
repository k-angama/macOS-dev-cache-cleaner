import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct CleanStorageCategoryUseCaseTests {

    @Test func streamsCleanupProgressAndFinishes() async throws {
        let repository = DiskRepositoryMock()
        repository.totalDiskCapacity = 500
        repository.availableDiskCapacity = 200
        repository.setComputeResponses([2.5, 0], for: ".pub-cache")
        repository.setCleanFileDeletionSteps([1.0, 1.5], for: ".pub-cache")

        let category = makeCategory(
            name: "Flutter",
            subcategories: [makeSubCategory(name: ".pub-cache")]
        )

        let events = await collectEvents(
            from: CleanStorageCategoryUseCase(diskRepository: repository).execute(
                homeURL: testHomeURL,
                category: category
            )
        )

        let firstEvent = try #require(events.first)
        let lastEvent = try #require(events.last)

        #expect(firstEvent.phase == .started)
        #expect(lastEvent.phase == .finished)
        #expect(abs(lastEvent.deletedSize - 2.5) < 0.0001)
        #expect(abs((lastEvent.updatedCategory?.size ?? -1) - 0) < 0.0001)
        #expect(lastEvent.didCompleteFully)
        #expect(repository.cleanedPaths == [repository.key(path: ".pub-cache", match: "")])
    }
}
