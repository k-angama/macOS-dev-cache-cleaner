//
//  WorkspaceAccessRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import Foundation

struct WorkspaceAccessRepositoryImpl: WorkspaceAccessRepository {
    private let manager: DirectoryAccessManaging

    init(manager: DirectoryAccessManaging) {
        self.manager = manager
    }

    func saveWorkspaceURL(_ url: URL) -> Bool {
        manager.saveAccess(for: url, kind: .workspace)
    }

    func resolveWorkspaceURL() -> URL? {
        manager.resolveURL(for: .workspace)
    }
}
