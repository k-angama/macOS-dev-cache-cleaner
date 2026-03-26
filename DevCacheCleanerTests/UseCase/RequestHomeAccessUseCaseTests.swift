import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct RequestHomeAccessUseCaseTests {

    @Test func returnsRequestedURL() {
        let repository = HomeAccessRepositoryMock()
        repository.requestedURL = testHomeURL

        let url = RequestHomeAccessUseCase(homeAccessRepository: repository).execute()

        #expect(repository.requestCallCount == 1)
        #expect(url == testHomeURL)
    }
}
