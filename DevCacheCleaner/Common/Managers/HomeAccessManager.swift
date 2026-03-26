//
//  HomeAccessManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 11/03/2026.
//

import Foundation
import AppKit

protocol HomeAccessManaging {
    func resolveHomeURL() -> URL?
    func requestAndSaveHomeAccess() -> URL?
    func ensureHomeAccess() -> URL?
}

final class HomeAccessManager: HomeAccessManaging {
    private var params: Parameters

    init(params: Parameters) {
        self.params = params
    }

    func resolveHomeURL() -> URL? {
        guard let data = params.homeFolderBookmark else { return nil }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data,
                              options: [.withSecurityScope],
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                saveBookmark(for: url)
            }
            return url
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }

    func requestAndSaveHomeAccess() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Grant Access"
        panel.message = "Select your Home folder"
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        if panel.runModal() == .OK, let url = panel.url {
            saveBookmark(for: url)
            return url
        }
        return nil
    }

    func ensureHomeAccess() -> URL? {
        if let url = resolveHomeURL() {
            return url
        }
        return requestAndSaveHomeAccess()
    }

    private func saveBookmark(for url: URL) {
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope],
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
            params.homeFolderBookmark = data
        } catch {
            print("Failed to create bookmark: \(error)")
        }
    }
}
