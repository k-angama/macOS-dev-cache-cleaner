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

    func computeDiskSize(homeURL: URL, path: String, match: String) async -> CGFloat {
        await manager.computeDiskSize(homeURL: homeURL, path: path, match: match)
    }

    func cleanPath(
        homeURL: URL,
        path: String,
        match: String,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws {
        try await manager.cleanPath(
            path: path,
            match: match,
            homeURL: homeURL,
            onFileDeleted: onFileDeleted
        )
    }
}
