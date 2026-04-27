import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct LaunchAtStartupUseCaseTests {

    @Test func resolveLaunchAtStartupStatus_returnsRepositoryStatus() {
        let repository = LaunchAtStartupRepositoryMock()
        repository.resolvedStatus = .requiresApproval

        let status = ResolveLaunchAtStartupStatusUseCase(
            launchAtStartupRepository: repository
        ).execute()

        #expect(status == .requiresApproval)
        #expect(repository.resolveCallCount == 1)
    }

    @Test func updateLaunchAtStartupStatus_updatesRepositoryWithRequestedValue() throws {
        let repository = LaunchAtStartupRepositoryMock()

        try UpdateLaunchAtStartupStatusUseCase(
            launchAtStartupRepository: repository
        ).execute(isEnabled: true)

        #expect(repository.updateCallCount == 1)
        #expect(repository.updatedIsEnabled == true)
        #expect(repository.resolvedStatus == .enabled)
    }
}
