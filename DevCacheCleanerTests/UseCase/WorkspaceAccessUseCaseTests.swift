import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct WorkspaceAccessUseCaseTests {

    @Test func saveWorkspaceAccess_savesURL() {
        let repository = WorkspaceAccessRepositoryMock()
        let url = URL(filePath: "/Users/test/Projects/MyApp")

        let didSave = SaveWorkspaceAccessUseCase(
            workspaceAccessRepository: repository
        ).execute(url: url)

        #expect(didSave)
        #expect(repository.savedURL == url)
        #expect(repository.saveCallCount == 1)
    }

    @Test func resolveWorkspaceAccess_returnsResolvedURL() {
        let repository = WorkspaceAccessRepositoryMock()
        let url = URL(filePath: "/Users/test/Projects/MyApp")
        repository.resolvedURL = url

        let resolvedURL = ResolveWorkspaceAccessUseCase(
            workspaceAccessRepository: repository
        ).execute()

        #expect(resolvedURL == url)
        #expect(repository.resolveCallCount == 1)
    }
}
