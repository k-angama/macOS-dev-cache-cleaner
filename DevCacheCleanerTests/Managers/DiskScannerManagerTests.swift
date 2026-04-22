import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct DiskScannerManagerTests {

    @Test func findWorkspaceCleanupDirectories_discoversSupportedGeneratedDirectories() async throws {
        let workspaceURL = try makeTemporaryWorkspaceURL()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        try writeEmptyFile(at: workspaceURL.appending(path: "package.json"))
        try createDirectory(at: workspaceURL.appending(path: "node_modules"))
        try writeEmptyFile(at: workspaceURL.appending(path: "App/Podfile"))
        try createDirectory(at: workspaceURL.appending(path: "App/Pods"))

        let paths = await DiskScannerManager().findWorkspaceCleanupDirectories(
            in: workspaceURL,
            rules: WorkspaceCleanupRuleEntity.supportedRules
        )

        #expect(paths == ["App/Pods", "node_modules"])
    }

    @Test func findWorkspaceCleanupDirectories_ignoresGeneratedDirectoriesWithoutMatchingMarkerFile() async throws {
        let workspaceURL = try makeTemporaryWorkspaceURL()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        try createDirectory(at: workspaceURL.appending(path: "node_modules"))
        try createDirectory(at: workspaceURL.appending(path: "Pods"))

        let paths = await DiskScannerManager().findWorkspaceCleanupDirectories(
            in: workspaceURL,
            rules: WorkspaceCleanupRuleEntity.supportedRules
        )

        #expect(paths.isEmpty)
    }
}
