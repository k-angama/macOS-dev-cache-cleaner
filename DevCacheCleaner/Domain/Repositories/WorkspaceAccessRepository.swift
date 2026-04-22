//
//  WorkspaceAccessRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import Foundation

protocol WorkspaceAccessRepository {
    func saveWorkspaceURL(_ url: URL) -> Bool
    func resolveWorkspaceURL() -> URL?
}
