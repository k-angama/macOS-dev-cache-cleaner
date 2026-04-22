//
//  DiskScannerRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import Foundation

struct DiskScannerRepositoryImpl: DiskScannerRepository {
    let manager: DiskScannerManager

    init(manager: DiskScannerManager) {
        self.manager = manager
    }

    func findWorkspaceCleanupDirectories(
        workspaceURL: URL,
        rules: [WorkspaceCleanupRuleEntity]
    ) async -> [String] {
        await manager.findWorkspaceCleanupDirectories(
            in: workspaceURL,
            rules: rules
        )
    }
}
