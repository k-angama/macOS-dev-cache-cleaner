import Foundation
@testable import DevCacheCleaner

final class DiskScannerRepositoryMock: DiskScannerRepository {

    private(set) var cleanupDirectoryRequests: [(URL, [WorkspaceCleanupRuleEntity])] = []
    var cleanupDirectories: [String] = []
    var cleanupDirectoryDelayNanoseconds: UInt64 = 0

    func findWorkspaceCleanupDirectories(
        workspaceURL: URL,
        rules: [WorkspaceCleanupRuleEntity]
    ) async -> [String] {
        cleanupDirectoryRequests.append((workspaceURL, rules))

        if cleanupDirectoryDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: cleanupDirectoryDelayNanoseconds)
        }

        return cleanupDirectories
    }
}
