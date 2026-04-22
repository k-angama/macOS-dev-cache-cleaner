import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct LoadWorkspaceCleanupCategoryUseCaseTests {

    @Test func execute_buildsCategoryFromScannerDirectoriesAndComputesSizes() async {
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")
        let diskRepository = DiskRepositoryMock()
        diskRepository.setComputeResponses([34], for: "App/Pods")
        diskRepository.setComputeResponses([12], for: "node_modules")

        let scannerRepository = DiskScannerRepositoryMock()
        scannerRepository.cleanupDirectories = ["App/Pods", "node_modules"]

        let category = await LoadWorkspaceCleanupCategoryUseCase(
            diskRepository: diskRepository,
            diskScannerRepository: scannerRepository
        ).execute(workspaceURL: workspaceURL)

        #expect(category.name == "Workspace: MyApp")
        #expect(abs(category.size - 46) < 0.0001)
        #expect(category.categories.map(\.path) == ["App/Pods", "node_modules"])
        #expect(category.categories.map(\.size) == [34, 12])
        #expect(diskRepository.computeRequests == [
            diskRepository.key(path: "App/Pods"),
            diskRepository.key(path: "node_modules")
        ])
        #expect(scannerRepository.cleanupDirectoryRequests.count == 1)
        #expect(scannerRepository.cleanupDirectoryRequests.first?.0 == workspaceURL)
        #expect(scannerRepository.cleanupDirectoryRequests.first?.1 == WorkspaceCleanupRuleEntity.supportedRules)
    }
}
