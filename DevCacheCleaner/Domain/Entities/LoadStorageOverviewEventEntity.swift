//
//  LoadStorageOverviewEventEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 02/04/2026.
//

import Foundation

struct LoadStorageOverviewEventEntity {

    enum Phase {
        case started
        case categoryUpdated
        case finished
    }

    let phase: Phase
    let categories: [StorageCategoryEntity]
    let updatedCategoryID: UUID?
    let totalSize: CGFloat
    let freeSize: CGFloat
}
