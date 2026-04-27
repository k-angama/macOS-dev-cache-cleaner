import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct SettingsViewModelTests {

    @Test func setup_whenLaunchAtStartupIsEnabled_updatesDisplayState() {
        let context = makeSUT(startupStatus: .enabled)

        #expect(context.viewModel.isLaunchAtStartupEnabled)
        #expect(
            context.viewModel.launchAtStartupStatusText ==
            "DevCacheCleaner will open automatically at startup."
        )
    }

    @Test func setLaunchAtStartupEnabled_whenApprovalIsRequired_showsAlert() {
        let context = makeSUT(startupStatus: .disabled)
        context.startupRepository.nextResolvedStatusAfterUpdate = .requiresApproval

        context.viewModel.setLaunchAtStartupEnabled(true)

        #expect(context.startupRepository.updateCallCount == 1)
        #expect(context.startupRepository.updatedIsEnabled == true)
        #expect(context.viewModel.isLaunchAtStartupEnabled)
        #expect(context.viewModel.isAlertErrorRequest)
        #expect(
            context.viewModel.alertErrorMessage ==
            "Approval is required in System Settings > Login Items."
        )
    }

    @Test func setLaunchAtStartupEnabled_whenUpdateFails_showsErrorAlert() {
        let context = makeSUT(startupStatus: .disabled)
        context.startupRepository.updateError = TestStartupError.unavailable

        context.viewModel.setLaunchAtStartupEnabled(true)

        #expect(context.startupRepository.updateCallCount == 1)
        #expect(context.viewModel.isLaunchAtStartupEnabled == false)
        #expect(context.viewModel.isAlertErrorRequest)
        #expect(
            context.viewModel.alertErrorMessage ==
            TestStartupError.unavailable.localizedDescription
        )
    }

    private func makeSUT(
        startupStatus: LaunchAtStartupStatusEntity
    ) -> SettingsViewModelTestContext {
        let workspaceRepository = WorkspaceAccessRepositoryMock()
        let startupRepository = LaunchAtStartupRepositoryMock()
        let settingsStore = SettingsStore()

        startupRepository.resolvedStatus = startupStatus

        let viewModel = SettingsViewModel(
            saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase(
                workspaceAccessRepository: workspaceRepository
            ),
            resolveLaunchAtStartupStatusUseCase: ResolveLaunchAtStartupStatusUseCase(
                launchAtStartupRepository: startupRepository
            ),
            updateLaunchAtStartupStatusUseCase: UpdateLaunchAtStartupStatusUseCase(
                launchAtStartupRepository: startupRepository
            ),
            settingsStore: settingsStore
        )

        return SettingsViewModelTestContext(
            viewModel: viewModel,
            startupRepository: startupRepository
        )
    }
}

private struct SettingsViewModelTestContext {
    let viewModel: SettingsViewModel
    let startupRepository: LaunchAtStartupRepositoryMock
}

private enum TestStartupError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        "Startup service unavailable."
    }
}
