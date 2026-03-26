//
//  StorageOverviewEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct StorageOverviewEntity {
    let totalSize: CGFloat
    let freeSize: CGFloat
    let categories: [StorageCategoryEntity]
}
