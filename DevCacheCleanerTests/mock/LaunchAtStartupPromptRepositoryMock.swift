import Foundation
@testable import DevCacheCleaner

final class LaunchAtStartupPromptRepositoryMock: LaunchAtStartupPromptRepository {

    var promptDismissed = false

    private(set) var isPromptDismissedCallCount = 0
    private(set) var setPromptDismissedCallCount = 0

    func isPromptDismissed() -> Bool {
        isPromptDismissedCallCount += 1
        return promptDismissed
    }

    func setPromptDismissed() {
        setPromptDismissedCallCount += 1
        promptDismissed = true
    }
}
