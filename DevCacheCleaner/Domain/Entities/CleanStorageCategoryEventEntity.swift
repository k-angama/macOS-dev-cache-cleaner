//
//  CleanStorageCategoryEventEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct CleanStorageCategoryEventEntity {

    enum Phase {
        case started
        case deletingDirectory
        case progressUpdated
        case finished
    }

    let phase: Phase
    let categoryName: String
    let currentDirectory: StorageSubCategoryEntity?
    let updatedCategory: StorageCategoryEntity?
    let deletedSize: CGFloat
    let totalSize: CGFloat
    let failedDirectories: [StorageSubCategoryEntity]
    let totalDiskCapacity: CGFloat?
    let availableDiskCapacity: CGFloat?

    var progress: Double {
        guard totalSize > 0 else {
            return phase == .finished ? 1 : 0
        }
        return min(max(Double(deletedSize / totalSize), 0), 1)
    }

    var didCompleteFully: Bool {
        phase == .finished && failedDirectories.isEmpty
    }
}
