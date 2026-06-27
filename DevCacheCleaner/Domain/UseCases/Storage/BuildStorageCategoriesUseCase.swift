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
                    name: storagePath.name.isEmpty ? nil : storagePath.name,
                    locations: storagePath.locations.map { location in
                        StorageLocationEntity(
                            path: location.path,
                            rule: location.rule,
                            size: 0
                        )
                    },
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
