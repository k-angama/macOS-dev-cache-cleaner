//
//  DirectoryAccessManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 11/03/2026.
//

import Foundation
import AppKit

enum DirectoryAccessKind {
    case home
    case workspace
}

protocol DirectoryAccessManaging {
    func resolveURL(for kind: DirectoryAccessKind) -> URL?
    func saveAccess(for url: URL, kind: DirectoryAccessKind) -> Bool
    func clearAccess(for kind: DirectoryAccessKind)
}

final class DirectoryAccessManager: DirectoryAccessManaging {
    private var params: Parameters

    init(params: Parameters) {
        self.params = params
    }

    func resolveURL(for kind: DirectoryAccessKind) -> URL? {
        guard let data = bookmarkData(for: kind) else { return nil }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data,
                              options: [.withSecurityScope],
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                _ = saveAccess(for: url, kind: kind)
            }
            return url
        } catch {
            print("Failed to resolve bookmark: \(error)")
            clearAccess(for: kind)
            return nil
        }
    }

    func saveAccess(for url: URL, kind: DirectoryAccessKind) -> Bool {
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope],
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
            setBookmarkData(data, for: kind)
            return true
        } catch {
            print("Failed to create bookmark: \(error)")
            return false
        }
    }

    func clearAccess(for kind: DirectoryAccessKind) {
        setBookmarkData(nil, for: kind)
    }

    private func bookmarkData(for kind: DirectoryAccessKind) -> Data? {
        switch kind {
        case .home:
            return params.homeFolderBookmark
        case .workspace:
            return params.workspaceFolderBookmark
        }
    }

    private func setBookmarkData(_ data: Data?, for kind: DirectoryAccessKind) {
        switch kind {
        case .home:
            params.homeFolderBookmark = data
        case .workspace:
            params.workspaceFolderBookmark = data
        }
    }
}
