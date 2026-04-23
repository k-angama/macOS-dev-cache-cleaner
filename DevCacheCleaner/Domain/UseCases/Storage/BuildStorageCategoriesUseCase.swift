//
//  BuildStorageCategoriesUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct BuildStorageCategoriesUseCase {

    func execute() -> [StorageCategoryEntity] {
        Constants.Storages.items.map { item in
            let subcategories = item.paths.map { storagePath in
                StorageSubCategoryEntity(
                    path: storagePath.path,
                    rule: storagePath.rule,
                    size: 0
                )
            }

            return StorageCategoryEntity(
                name: item.title,
                color: item.color,
                size: 0,
                categories: subcategories
            )
        }
    }
}
