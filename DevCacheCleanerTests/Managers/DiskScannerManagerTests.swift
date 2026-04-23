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
        try writeEmptyFile(at: workspaceURL.appending(path: "Package.swift"))
        try createDirectory(at: workspaceURL.appending(path: ".build"))
        try writeEmptyFile(at: workspaceURL.appending(path: "Android/settings.gradle.kts"))
        try createDirectory(at: workspaceURL.appending(path: "Android/.gradle"))
        try writeEmptyFile(at: workspaceURL.appending(path: "Android/app/build.gradle.kts"))
        try createDirectory(at: workspaceURL.appending(path: "Android/app/build"))

        let paths = await DiskScannerManager().findWorkspaceCleanupDirectories(
            in: workspaceURL,
            rules: WorkspaceCleanupRuleEntity.supportedRules
        )

        #expect(paths == [".build", "Android/.gradle", "Android/app/build", "App/Pods", "node_modules"])
    }

    @Test func findWorkspaceCleanupDirectories_ignoresGeneratedDirectoriesWithoutMatchingMarkerFile() async throws {
        let workspaceURL = try makeTemporaryWorkspaceURL()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        try createDirectory(at: workspaceURL.appending(path: "node_modules"))
        try createDirectory(at: workspaceURL.appending(path: "Pods"))
        try createDirectory(at: workspaceURL.appending(path: ".build"))
        try createDirectory(at: workspaceURL.appending(path: ".gradle"))
        try createDirectory(at: workspaceURL.appending(path: "build"))

        let paths = await DiskScannerManager().findWorkspaceCleanupDirectories(
            in: workspaceURL,
            rules: WorkspaceCleanupRuleEntity.supportedRules
        )

        #expect(paths.isEmpty)
    }
}
