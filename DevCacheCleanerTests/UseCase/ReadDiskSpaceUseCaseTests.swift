import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct ReadDiskSpaceUseCaseTests {

    @Test func readsDiskTotalsFromRepository() {
        let repository = DiskRepositoryMock()
        repository.totalDiskCapacity = 512
        repository.availableDiskCapacity = 128

        let diskSpace = ReadDiskSpaceUseCase(diskRepository: repository).execute()

        #expect(diskSpace.totalSize == 512)
        #expect(diskSpace.freeSize == 128)
    }
}
