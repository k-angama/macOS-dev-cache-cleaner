import Foundation
@testable import DevCacheCleaner

final class HomeAccessRepositoryMock: HomeAccessRepository {

    var requestedURL: URL?
    var resolvedURL: URL?

    private(set) var requestCallCount = 0
    private(set) var resolveCallCount = 0

    func requestAndSaveHomeAccess() -> URL? {
        requestCallCount += 1
        return requestedURL
    }

    func resolveHomeURL() -> URL? {
        resolveCallCount += 1
        return resolvedURL
    }
}
