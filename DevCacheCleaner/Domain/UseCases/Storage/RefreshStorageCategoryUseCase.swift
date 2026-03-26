//
//  RefreshStorageCategoryUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct RefreshStorageCategoryUseCase {

    private let diskRepository: DiskRepository

    init(diskRepository: DiskRepository) {
        self.diskRepository = diskRepository
    }

    func execute(
        homeURL: URL,
        category: StorageCategoryEntity
    ) async -> StorageCategoryEntity {
        var updatedCategory = category

        for (index, subCategory) in category.categories.enumerated() {
            guard Task.isCancelled == false else {
                return updatedCategory.updateSize()
            }

            let size = await diskRepository.computeDiskSize(
                homeURL: homeURL,
                path: subCategory.path,
                match: subCategory.match
            )
            let updatedSubCategory = subCategory.updateSize(size: size)

            updatedCategory = updatedCategory
                .updateCategory(index: index, subCategory: updatedSubCategory)
                .updateSize()
        }

        return updatedCategory
    }
}
