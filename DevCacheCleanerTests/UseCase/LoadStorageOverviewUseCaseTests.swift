import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct LoadStorageOverviewUseCaseTests {

    @Test func buildsAndRefreshesOverview() async {
        let repository = DiskRepositoryMock()
        repository.totalDiskCapacity = 256
        repository.availableDiskCapacity = 64
        repository.setComputeResponses([3.5], for: ".pub-cache")

        let overview = await LoadStorageOverviewUseCase(
            diskRepository: repository,
            buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase(),
            refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase(diskRepository: repository)
        ).execute(homeURL: testHomeURL)

        let flutterCategory = overview.categories.first {
            $0.categories.contains(where: { $0.path == ".pub-cache" })
        }

        #expect(overview.totalSize == 256)
        #expect(overview.freeSize == 64)
        #expect(flutterCategory != nil)
        #expect(abs((flutterCategory?.size ?? 0) - 3.5) < 0.0001)
    }
}
