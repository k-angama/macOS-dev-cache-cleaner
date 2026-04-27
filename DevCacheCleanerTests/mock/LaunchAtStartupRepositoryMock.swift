import Foundation
@testable import DevCacheCleaner

final class LaunchAtStartupRepositoryMock: LaunchAtStartupRepository {

    var resolvedStatus: LaunchAtStartupStatusEntity = .disabled
    var nextResolvedStatusAfterUpdate: LaunchAtStartupStatusEntity?
    var updateError: Error?

    private(set) var updateCallCount = 0
    private(set) var resolveCallCount = 0
    private(set) var updatedIsEnabled: Bool?

    func resolveStatus() -> LaunchAtStartupStatusEntity {
        resolveCallCount += 1
        return resolvedStatus
    }

    func update(isEnabled: Bool) throws {
        updateCallCount += 1
        updatedIsEnabled = isEnabled

        if let updateError {
            throw updateError
        }

        if let nextResolvedStatusAfterUpdate {
            resolvedStatus = nextResolvedStatusAfterUpdate
            self.nextResolvedStatusAfterUpdate = nil
            return
        }

        resolvedStatus = isEnabled ? .enabled : .disabled
    }
}
