//
//  StorageCategoryEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 05/03/2026.
//

import SwiftUI

public enum StoragePathRule: Codable, Hashable {
    case allContents
    case childNamePrefix(String)

    var displayDescription: String {
        switch self {
        case .allContents:
            return "Cleans all contents"
        case .childNamePrefix(let prefix):
            return "Cleans child items matching: \(prefix)*"
        }
    }
}

struct StorageCategoryEntity: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let color: Color
    var size: CGFloat
    var categories: [StorageSubCategoryEntity]
    
    func updateSize() -> StorageCategoryEntity {
        StorageCategoryEntity(
            id: self.id,
            name: self.name,
            color: self.color,
            size: self.categories.reduce(0) { $0 + $1.size },
            categories: self.categories
        )
    }
    
    func updateCategory(index: Int, subCategory: StorageSubCategoryEntity) -> StorageCategoryEntity {
        let newSubcategories = self.categories.enumerated().map { idx, sub in
            idx == index ? subCategory : sub
        }
        return StorageCategoryEntity(
            id: self.id,
            name: self.name,
            color: self.color,
            size: self.size,
            categories: newSubcategories
        )
    }
}

struct StorageSubCategoryEntity: Identifiable, Codable, Hashable  {
    var id: UUID = UUID()
    let path: String
    let rule: StoragePathRule
    var size: CGFloat
    
    func updateSize(size: CGFloat) -> StorageSubCategoryEntity {
        StorageSubCategoryEntity(
            id: self.id,
            path: self.path,
            rule: self.rule,
            size: size
        )
    }
}


extension StorageCategoryEntity {

    static var preview: StorageCategoryEntity {
        StorageCategoryEntity(
            name: "Xcode Caches & DerivedData",
            color: .red,
            size: 10,
            categories: []
        )
    }

}
