import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct ResolveHomeAccessUseCaseTests {

    @Test func returnsResolvedURL() {
        let repository = HomeAccessRepositoryMock()
        repository.resolvedURL = testHomeURL

        let url = ResolveHomeAccessUseCase(homeAccessRepository: repository).execute()

        #expect(repository.resolveCallCount == 1)
        #expect(url == testHomeURL)
    }
}
