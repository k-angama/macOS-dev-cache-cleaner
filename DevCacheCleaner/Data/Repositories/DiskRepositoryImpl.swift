//
//  DiskRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

struct DiskRepositoryImpl: DiskRepository {
    let manager: DiskManager

    init(manager: DiskManager) {
        self.manager = manager
    }

    var totalDiskCapacity: CGFloat { manager.totalDiskCapacity }
    var availableDiskCapacity: CGFloat { manager.availableDiskCapacity }

    func computeDiskSize(homeURL: URL, path: String, rule: StoragePathRule) async -> CGFloat {
        await manager.computeDiskSize(homeURL: homeURL, path: path, rule: rule)
    }

    func cleanPath(
        homeURL: URL,
        path: String,
        rule: StoragePathRule,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws {
        try await manager.cleanPath(
            path: path,
            rule: rule,
            homeURL: homeURL,
            onFileDeleted: onFileDeleted
        )
    }
}
