//
//  DiskScannerRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import Foundation

protocol DiskScannerRepository {
    func findWorkspaceCleanupDirectories(
        workspaceURL: URL,
        rules: [WorkspaceCleanupRuleEntity]
    ) async -> [String]
}
