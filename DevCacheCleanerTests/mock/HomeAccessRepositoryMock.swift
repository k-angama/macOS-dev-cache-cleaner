import Foundation
@testable import DevCacheCleaner

final class HomeAccessRepositoryMock: HomeAccessRepository {

    var savedURL: URL?
    var resolvedURL: URL?
    var shouldSaveHomeURL = true

    private(set) var saveCallCount = 0
    private(set) var resolveCallCount = 0

    func saveHomeURL(_ url: URL) -> Bool {
        saveCallCount += 1
        savedURL = url
        return shouldSaveHomeURL
    }

    func resolveHomeURL() -> URL? {
        resolveCallCount += 1
        return resolvedURL
    }
}
