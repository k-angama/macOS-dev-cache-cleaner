import Foundation
@testable import DevCacheCleaner

final class WorkspaceAccessRepositoryMock: WorkspaceAccessRepository {

    var savedURL: URL?
    var resolvedURL: URL?
    var shouldSaveWorkspaceURL = true

    private(set) var saveCallCount = 0
    private(set) var resolveCallCount = 0
    private(set) var clearCallCount = 0

    func saveWorkspaceURL(_ url: URL) -> Bool {
        saveCallCount += 1
        savedURL = url
        return shouldSaveWorkspaceURL
    }

    func resolveWorkspaceURL() -> URL? {
        resolveCallCount += 1
        return resolvedURL
    }

    func clearWorkspaceURL() {
        clearCallCount += 1
        resolvedURL = nil
    }
}
