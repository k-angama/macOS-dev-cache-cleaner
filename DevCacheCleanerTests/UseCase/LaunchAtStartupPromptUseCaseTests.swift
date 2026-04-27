import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct LaunchAtStartupPromptUseCaseTests {

    @Test func resolveLaunchAtStartupPromptDismissal_returnsRepositoryValue() {
        let repository = LaunchAtStartupPromptRepositoryMock()
        repository.promptDismissed = true

        let isDismissed = ResolveLaunchAtStartupPromptDismissalUseCase(
            launchAtStartupPromptRepository: repository
        ).execute()

        #expect(isDismissed)
        #expect(repository.isPromptDismissedCallCount == 1)
    }

    @Test func dismissLaunchAtStartupPrompt_marksPromptAsDismissed() {
        let repository = LaunchAtStartupPromptRepositoryMock()

        DismissLaunchAtStartupPromptUseCase(
            launchAtStartupPromptRepository: repository
        ).execute()

        #expect(repository.promptDismissed)
        #expect(repository.setPromptDismissedCallCount == 1)
    }
}
