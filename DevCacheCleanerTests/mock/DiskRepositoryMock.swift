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

    func setComputeResponses(_ responses: [CGFloat], for path: String, match: String = "") {
        lock.lock()
        computeResponses[key(path: path, match: match)] = responses
        lock.unlock()
    }

    func setComputeDelay(_ delayNanoseconds: UInt64, for path: String, match: String = "") {
        lock.lock()
        computeDelays[key(path: path, match: match)] = delayNanoseconds
        lock.unlock()
    }

    func setCleanFileDeletionSteps(_ steps: [CGFloat], for path: String, match: String = "") {
        lock.lock()
        cleanFileDeletionSteps[key(path: path, match: match)] = steps
        lock.unlock()
    }

    func setCleanError(_ error: Error, for path: String, match: String = "") {
        lock.lock()
        cleanErrors[key(path: path, match: match)] = error
        lock.unlock()
    }

    func key(path: String, match: String) -> String {
        "\(path)|\(match)"
    }

    func computeDiskSize(homeURL: URL, path: String, match: String) async -> CGFloat {
        let key = key(path: path, match: match)
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
        match: String,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws {
        let key = key(path: path, match: match)
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
