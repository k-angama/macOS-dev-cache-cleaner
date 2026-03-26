//
//  LoadStorageOverviewUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct LoadStorageOverviewUseCase {

    private let diskRepository: DiskRepository
    private let buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase
    private let refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase

    init(
        diskRepository: DiskRepository,
        buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase
    ) {
        self.diskRepository = diskRepository
        self.buildStorageCategoriesUseCase = buildStorageCategoriesUseCase
        self.refreshStorageCategoryUseCase = refreshStorageCategoryUseCase
    }

    func execute(homeURL: URL) async -> StorageOverviewEntity {
        var categories = buildStorageCategoriesUseCase.execute()

        for index in categories.indices {
            categories[index] = await refreshStorageCategoryUseCase.execute(
                homeURL: homeURL,
                category: categories[index]
            )
        }

        return StorageOverviewEntity(
            totalSize: diskRepository.totalDiskCapacity,
            freeSize: diskRepository.availableDiskCapacity,
            categories: categories
        )
    }
}
