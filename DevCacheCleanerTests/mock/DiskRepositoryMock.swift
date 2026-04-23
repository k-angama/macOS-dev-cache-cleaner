import Foundation
@testable import DevCacheCleaner

final class DiskRepositoryMock: DiskRepository {

    var totalDiskCapacity: CGFloat = 0
    var availableDiskCapacity: CGFloat = 0

    private let lock = NSLock()
    private var computeResponses: [String: [CGFloat]] = [:]
    private var computeDelays: [String: UInt64] = [:]
    private var cleanFileDeletionSteps: [String: [CGFloat]] = [:]
    private var cleanErrors: [String: Error] = [:]

    private(set) var cleanedPaths: [String] = []
    private(set) var computeRequests: [String] = []

    func setComputeResponses(_ responses: [CGFloat], for path: String, rule: StoragePathRule = .allContents) {
        lock.lock()
        computeResponses[key(path: path, rule: rule)] = responses
        lock.unlock()
    }

    func setComputeDelay(_ delayNanoseconds: UInt64, for path: String, rule: StoragePathRule = .allContents) {
        lock.lock()
        computeDelays[key(path: path, rule: rule)] = delayNanoseconds
        lock.unlock()
    }

    func setCleanFileDeletionSteps(_ steps: [CGFloat], for path: String, rule: StoragePathRule = .allContents) {
        lock.lock()
        cleanFileDeletionSteps[key(path: path, rule: rule)] = steps
        lock.unlock()
    }

    func setCleanError(_ error: Error, for path: String, rule: StoragePathRule = .allContents) {
        lock.lock()
        cleanErrors[key(path: path, rule: rule)] = error
        lock.unlock()
    }

    func key(path: String, rule: StoragePathRule = .allContents) -> String {
        "\(path)|\(rule)"
    }

    func computeDiskSize(homeURL: URL, path: String, rule: StoragePathRule) async -> CGFloat {
        let key = key(path: path, rule: rule)
        lock.lock()
        computeRequests.append(key)
        let delayNanoseconds = computeDelays[key] ?? 0

        guard var responses = computeResponses[key], responses.isEmpty == false else {
            lock.unlock()

            if delayNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: delayNanoseconds)
            }

            return 0
        }

        let value = responses.removeFirst()
        computeResponses[key] = responses
        lock.unlock()

        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }

        return value
    }

    func cleanPath(
        homeURL: URL,
        path: String,
        rule: StoragePathRule,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws {
        let key = key(path: path, rule: rule)
        lock.lock()
        cleanedPaths.append(key)
        let deletionSteps = cleanFileDeletionSteps[key] ?? []
        let error = cleanErrors[key]
        lock.unlock()

        for deletedSize in deletionSteps {
            onFileDeleted?(deletedSize)
        }

        if let error {
            throw error
        }
    }
}
