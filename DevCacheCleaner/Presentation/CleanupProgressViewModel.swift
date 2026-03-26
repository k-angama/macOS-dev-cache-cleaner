//
//  CleanupProgressViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 11/03/2026.
//

import Foundation
import SwiftUI

@Observable
class CleanupProgressViewModel {

    private let store: CleanupProgressStore
    
    var progressPercentage: Int {
        Int((store.progress * 100).rounded())
    }

    var deletedSizeText: String {
        store.deletedSize.byteCountString
    }

    var totalSizeText: String {
        store.totalSize.byteCountString
    }
    
    var currentDirectoryPath: String? {
        store.currentDirectory?.path
    }
    
    var progress: Double {
        store.progress
    }
    
    var isFinished: Bool {
        store.isFinished
    }
    
    var shouldDismiss: Bool {
        store.shouldDismiss
    }
    
    var categoryName: String {
        store.categoryName
    }

    init(store: CleanupProgressStore) {
        self.store = store
    }

    func setCategoryName(_ name: String) {
        store.setCategoryName(name)
    }
}
