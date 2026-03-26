//
//  DiskScannerManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 12/03/2026.
//

import Foundation

class DiskScannerManager {
    
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
    
}
