import Foundation
@testable import DevCacheCleaner

final class DiskMonitoringRepositoryMock: DiskMonitoringRepository {

    var folderDidChange: ((String) -> Void)?

    private(set) var startedURL: URL?
    private(set) var stopCallCount = 0

    func startMonitoring(url: URL) {
        startedURL = url
    }

    func stopMonitoring() {
        stopCallCount += 1
    }
}
