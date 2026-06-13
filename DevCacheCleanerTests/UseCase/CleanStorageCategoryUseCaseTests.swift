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
        #expect(repository.cleanedPaths == [repository.key(path: ".pub-cache")])
        #expect(repository.cleanedExpectedSizes == [2.5])
    }

    @Test func cleansEveryLocationInGroupedSubcategory() async throws {
        let repository = DiskRepositoryMock()
        repository.setComputeResponses([1, 0], for: "Cache/A")
        repository.setComputeResponses(
            [2, 0],
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

        let events = await collectEvents(
            from: CleanStorageCategoryUseCase(diskRepository: repository).execute(
                homeURL: testHomeURL,
                category: category
            )
        )
        let lastEvent = try #require(events.last)

        #expect(repository.cleanedPaths == [
            repository.key(path: "Cache/A"),
            repository.key(path: "Cache/B", rule: .childNamePrefix("match")),
        ])
        #expect(repository.cleanedExpectedSizes == [1, 2])
        #expect(lastEvent.updatedCategory?.categories.count == 1)
        #expect(lastEvent.updatedCategory?.categories[0].locations.map(\.size) == [0, 0])
        #expect(lastEvent.deletedSize == 3)
        #expect(lastEvent.didCompleteFully)
    }

    @Test func reportsOnlyFailedLocationFromGroupedSubcategory() async throws {
        struct ExpectedError: Error {}

        let repository = DiskRepositoryMock()
        repository.setComputeResponses([1, 1], for: "Cache/A")
        repository.setComputeResponses([2, 0], for: "Cache/B")
        repository.setCleanError(ExpectedError(), for: "Cache/A")
        let first = StorageLocationEntity(
            path: "Cache/A",
            rule: .allContents,
            size: 0
        )
        let second = StorageLocationEntity(
            path: "Cache/B",
            rule: .allContents,
            size: 0
        )
        let category = makeCategory(
            name: "Grouped",
            subcategories: [
                makeSubCategory(name: "Tool", locations: [first, second])
            ]
        )

        let events = await collectEvents(
            from: CleanStorageCategoryUseCase(diskRepository: repository).execute(
                homeURL: testHomeURL,
                category: category
            )
        )
        let lastEvent = try #require(events.last)
        let failure = try #require(lastEvent.failedDirectories.first)

        #expect(lastEvent.failedDirectories.count == 1)
        #expect(failure.locations.map(\.id) == [first.id])
        #expect(failure.locations.map(\.path) == ["Cache/A"])
        #expect(lastEvent.didCompleteFully == false)
    }
}
