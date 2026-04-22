//
//  LoadWorkspaceCleanupCategoryUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import Foundation
import SwiftUI

struct LoadWorkspaceCleanupCategoryUseCase {

    private let diskRepository: DiskRepository
    private let diskScannerRepository: DiskScannerRepository
    private let rules: [WorkspaceCleanupRuleEntity]

    init(
        diskRepository: DiskRepository,
        diskScannerRepository: DiskScannerRepository,
        rules: [WorkspaceCleanupRuleEntity] = WorkspaceCleanupRuleEntity.supportedRules
    ) {
        self.diskRepository = diskRepository
        self.diskScannerRepository = diskScannerRepository
        self.rules = rules
    }

    func execute(workspaceURL: URL) async -> StorageCategoryEntity {
        let directories = await diskScannerRepository.findWorkspaceCleanupDirectories(
            workspaceURL: workspaceURL,
            rules: rules
        )
        var subcategories: [StorageSubCategoryEntity] = []

        for directory in directories {
            guard Task.isCancelled == false else {
                break
            }

            let size = await diskRepository.computeDiskSize(
                homeURL: workspaceURL,
                path: directory,
                rule: .allContents
            )

            subcategories.append(
                StorageSubCategoryEntity(
                    path: directory,
                    rule: .allContents,
                    size: size
                )
            )
        }

        return StorageCategoryEntity(
            name: "Workspace: \(workspaceURL.lastPathComponent)",
            color: .teal,
            size: subcategories.reduce(0) { $0 + $1.size },
            categories: subcategories
        )
    }
}
