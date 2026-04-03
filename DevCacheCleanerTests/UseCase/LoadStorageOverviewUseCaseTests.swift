import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct LoadStorageOverviewUseCaseTests {

    @Test func streamsOverviewLoadingProgressively() async {
        let repository = DiskRepositoryMock()
        repository.totalDiskCapacity = 256
        repository.availableDiskCapacity = 64
        repository.setComputeResponses([3.5], for: ".pub-cache")

        let events = await collectLoadStorageOverviewEvents(
            from: LoadStorageOverviewUseCase(
                diskRepository: repository,
                buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase(),
                refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase(diskRepository: repository)
            ).execute(homeURL: testHomeURL)
        )

        let startedEvent = events.first
        let finishedEvent = events.last
        let categoryUpdatedEvents = events.filter { $0.phase == .categoryUpdated }
        let flutterCategory = finishedEvent?.categories.first {
            $0.categories.contains(where: { $0.path == ".pub-cache" })
        }

        #expect(startedEvent?.phase == .started)
        #expect(finishedEvent?.phase == .finished)
        #expect(categoryUpdatedEvents.count == startedEvent?.categories.count)
        #expect(finishedEvent?.totalSize == 256)
        #expect(finishedEvent?.freeSize == 64)
        #expect(flutterCategory != nil)
        #expect(abs((flutterCategory?.size ?? 0) - 3.5) < 0.0001)
    }

    @Test func emitsCategoryUpdatesWhenTheyFinish() async {
        let repository = DiskRepositoryMock()

        repository.setComputeDelay(40_000_000, for: "Library/Caches/CocoaPods")
        repository.setComputeDelay(40_000_000, for: "Library/Application Support/Code/Cache")
        repository.setComputeDelay(40_000_000, for: "Library/Application Support/Code/CachedData")
        repository.setComputeDelay(40_000_000, for: "Library/Application Support/Code/User/workspaceStorage")
        repository.setComputeResponses([3.5], for: ".pub-cache")

        let events = await collectLoadStorageOverviewEvents(
            from: LoadStorageOverviewUseCase(
                diskRepository: repository,
                buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase(),
                refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase(diskRepository: repository)
            ).execute(homeURL: testHomeURL)
        )

        let updatedCategoryNames = categoryUpdatedNames(from: events)
        let flutterIndex = updatedCategoryNames.firstIndex(of: "Flutter/pub-cache")
        let ideIndex = updatedCategoryNames.firstIndex(of: "IDE (JetBrains, VSCode) Caches")

        #expect(flutterIndex != nil)
        #expect(ideIndex != nil)
        #expect((flutterIndex ?? .max) < (ideIndex ?? .max))
    }

    private func collectLoadStorageOverviewEvents(
        from stream: AsyncStream<LoadStorageOverviewEventEntity>
    ) async -> [LoadStorageOverviewEventEntity] {
        var events: [LoadStorageOverviewEventEntity] = []

        for await event in stream {
            events.append(event)
        }

        return events
    }

    private func categoryUpdatedNames(
        from events: [LoadStorageOverviewEventEntity]
    ) -> [String] {
        events.compactMap { event in
            guard
                event.phase == .categoryUpdated,
                let updatedCategoryID = event.updatedCategoryID
            else {
                return nil
            }

            return event.categories.first(where: { $0.id == updatedCategoryID })?.name
        }
    }
}
