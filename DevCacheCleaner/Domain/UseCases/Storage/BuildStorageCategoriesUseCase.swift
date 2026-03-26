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
            let subcategories = item.paths.map { path, match in
                StorageSubCategoryEntity(path: path, match: match, size: 0)
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
