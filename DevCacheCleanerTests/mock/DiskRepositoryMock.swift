import Foundation
@testable import DevCacheCleaner

final class DiskRepositoryMock: DiskRepository {

    var totalDiskCapacity: CGFloat = 0
    var availableDiskCapacity: CGFloat = 0

    private var computeResponses: [String: [CGFloat]] = [:]
    private var cleanFileDeletionSteps: [String: [CGFloat]] = [:]
    private var cleanErrors: [String: Error] = [:]

    private(set) var cleanedPaths: [String] = []
    private(set) var computeRequests: [String] = []

    func setComputeResponses(_ responses: [CGFloat], for path: String, match: String = "") {
        computeResponses[key(path: path, match: match)] = responses
    }

    func setCleanFileDeletionSteps(_ steps: [CGFloat], for path: String, match: String = "") {
        cleanFileDeletionSteps[key(path: path, match: match)] = steps
    }

    func setCleanError(_ error: Error, for path: String, match: String = "") {
        cleanErrors[key(path: path, match: match)] = error
    }

    func key(path: String, match: String) -> String {
        "\(path)|\(match)"
    }

    func computeDiskSize(homeURL: URL, path: String, match: String) async -> CGFloat {
        let key = key(path: path, match: match)
        computeRequests.append(key)

        guard var responses = computeResponses[key], responses.isEmpty == false else {
            return 0
        }

        let value = responses.removeFirst()
        computeResponses[key] = responses
        return value
    }

    func cleanPath(
        homeURL: URL,
        path: String,
        match: String,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws {
        let key = key(path: path, match: match)
        cleanedPaths.append(key)

        for deletedSize in cleanFileDeletionSteps[key] ?? [] {
            onFileDeleted?(deletedSize)
        }

        if let error = cleanErrors[key] {
            throw error
        }
    }
}
