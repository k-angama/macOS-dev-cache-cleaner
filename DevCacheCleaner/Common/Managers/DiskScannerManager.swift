//
//  DiskScannerManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 12/03/2026.
//

import Foundation

class DiskScannerManager {
    /*
    func findAllPubspecs(in homeURL: URL) -> [URL] {
        var results: [URL] = []
        homeURL.withSecurityScope {
            let fm = FileManager.default
            let options: FileManager.DirectoryEnumerationOptions = [
                .skipsHiddenFiles
            ]
            if let enumerator = fm.enumerator(
                at: homeURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: options
            ) {
                for case let url as URL in enumerator {
                    // Skip obviously problematic directories if you want to speed up:
                    // e.g., node_modules, .git, build output directories, etc.
                    let last = url.lastPathComponent
                    if last == "node_modules" || last == ".git" || last == ".gradle" {
                        enumerator.skipDescendants()
                        continue
                    }

                    if url.lastPathComponent == "pubspec.yaml" {
                        let dirURL = url.deletingLastPathComponent()
                        if !results.contains(dirURL) {
                            results.append(dirURL)
                        }
                    }
                }
            }
        }
        return results
    }
*/
    func findWorkspaceCleanupDirectories(
        in workspaceURL: URL,
        rules: [WorkspaceCleanupRuleEntity]
    ) async -> [String] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: [])
                    return
                }

                let directories = self.scanWorkspaceCleanupDirectories(
                    in: workspaceURL,
                    rules: rules
                )
                continuation.resume(returning: directories)
            }
        }
    }

    private func scanWorkspaceCleanupDirectories(
        in workspaceURL: URL,
        rules: [WorkspaceCleanupRuleEntity]
    ) -> [String] {
        var targets = Set<String>()

        workspaceURL.withSecurityScope {
            addWorkspaceCleanupDirectories(
                in: workspaceURL,
                workspaceURL: workspaceURL,
                rules: rules,
                to: &targets
            )

            let options: FileManager.DirectoryEnumerationOptions = [
                .skipsHiddenFiles,
                .skipsPackageDescendants
            ]

            guard let enumerator = FileManager.default.enumerator(
                at: workspaceURL,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
                options: options
            ) else {
                return
            }

            for case let url as URL in enumerator {
                guard isScannableDirectory(url) else {
                    continue
                }

                if shouldSkipDescendants(of: url, rules: rules) {
                    enumerator.skipDescendants()
                    continue
                }

                addWorkspaceCleanupDirectories(
                    in: url,
                    workspaceURL: workspaceURL,
                    rules: rules,
                    to: &targets
                )
            }
        }

        return targets.sorted {
            $0.localizedStandardCompare($1) == .orderedAscending
        }
    }

    private func addWorkspaceCleanupDirectories(
        in projectURL: URL,
        workspaceURL: URL,
        rules: [WorkspaceCleanupRuleEntity],
        to targets: inout Set<String>
    ) {
        for rule in rules {
            let generatedDirectoryURL = projectURL.appending(
                path: rule.generatedDirectoryName,
                directoryHint: .isDirectory
            )

            guard
                hasMarkerFile(for: rule, in: projectURL),
                isDirectory(generatedDirectoryURL),
                let path = relativePath(from: workspaceURL, to: generatedDirectoryURL)
            else {
                continue
            }

            targets.insert(path)
        }
    }

    private func hasMarkerFile(for rule: WorkspaceCleanupRuleEntity, in projectURL: URL) -> Bool {
        rule.markerFileNames.contains { markerFileName in
            FileManager.default.fileExists(atPath: projectURL.appending(path: markerFileName).path)
        }
    }

    private func isScannableDirectory(_ url: URL) -> Bool {
        guard let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey]) else {
            return false
        }

        return values.isDirectory == true && values.isSymbolicLink != true
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false

        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return false
        }

        return isDirectory.boolValue
    }

    private func shouldSkipDescendants(
        of url: URL,
        rules: [WorkspaceCleanupRuleEntity]
    ) -> Bool {
        let generatedDirectoryNames = rules.map(\.generatedDirectoryName)
        let skippedDirectoryNames = Set(
            generatedDirectoryNames + [".git", ".swiftpm", ".build", "build", "DerivedData"]
        )

        return skippedDirectoryNames.contains(url.lastPathComponent)
    }

    private func relativePath(from workspaceURL: URL, to targetURL: URL) -> String? {
        let workspacePath = workspaceURL.standardizedFileURL.path
        let targetPath = targetURL.standardizedFileURL.path

        guard targetPath.hasPrefix(workspacePath + "/") else {
            return nil
        }

        return String(targetPath.dropFirst(workspacePath.count + 1))
    }
    
}
