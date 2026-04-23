import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct SaveHomeAccessUseCaseTests {

    @Test func execute_whenRepositorySavesHomeURL_returnsTrue() {
        let repository = HomeAccessRepositoryMock()

        let didSave = SaveHomeAccessUseCase(homeAccessRepository: repository).execute(url: testHomeURL)

        #expect(repository.saveCallCount == 1)
        #expect(repository.savedURL == testHomeURL)
        #expect(didSave)
    }

    @Test func execute_whenRepositoryFailsToSaveHomeURL_returnsFalse() {
        let repository = HomeAccessRepositoryMock()
        repository.shouldSaveHomeURL = false

        let didSave = SaveHomeAccessUseCase(homeAccessRepository: repository).execute(url: testHomeURL)

        #expect(repository.saveCallCount == 1)
        #expect(repository.savedURL == testHomeURL)
        #expect(didSave == false)
    }
}
