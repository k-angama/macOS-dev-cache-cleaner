import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct ObserveDiskChangesUseCaseTests {

    @Test func startsAndStopsMonitoring() {
        let repository = DiskMonitoringRepositoryMock()
        let useCase = ObserveDiskChangesUseCase(diskMonitoringRepository: repository)
        var changedPath: String?

        useCase.start(url: testHomeURL) { path in
            changedPath = path
        }

        repository.folderDidChange?("Library/Caches")

        #expect(repository.startedURL == testHomeURL)
        #expect(changedPath == "Library/Caches")

        useCase.stop()

        #expect(repository.stopCallCount == 1)
        #expect(repository.folderDidChange == nil)
    }
}
