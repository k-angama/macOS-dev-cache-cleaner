//
//  StorageCategoryDetailsDI.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

struct StorageCategoryDetailsDI: PresentationDI {
    
    static func start(
        data: (
            category: StorageCategoryEntity,
            onCleanSelected: (([StorageSubCategoryEntity]) -> Void)?
        )
    ) -> StorageCategoryDetailsView {
        let viewModel = StorageCategoryDetailsViewModel(
            category: data.category
        )
        return StorageCategoryDetailsView(
            onCleanSelected: data.onCleanSelected, viewModel: viewModel
        )
    }
    
}
