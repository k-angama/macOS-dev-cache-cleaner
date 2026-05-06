//
//  CleanupProgressDI.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

final class CleanupProgressDI: PresentationDI {
    private let store: CleanupProgressStore

    init(store: CleanupProgressStore) {
        self.store = store
    }

    func start(data selectedCategoryName: String) -> CleanupProgressView {
        viewModel.setCategoryName(selectedCategoryName)
        return CleanupProgressView(viewModel: viewModel)
    }

    private lazy var viewModel = CleanupProgressViewModel(
        store: store
    )
}
