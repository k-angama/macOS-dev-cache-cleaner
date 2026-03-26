//
//  CleanupProgressStore.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation
import SwiftUI

@Observable
final class CleanupProgressStore {
    // Shared state for the cleanup window. The home view model writes progress here,
    // while the progress window only reads and displays it.

    var categoryName: String = ""
    var currentDirectory: StorageSubCategoryEntity?
    var totalSize: CGFloat = 0
    var deletedSize: CGFloat = 0
    var isFinished: Bool = false
    var shouldDismiss: Bool = false

    // Prevents an old auto-dismiss task from closing a newer cleanup window.
    private var activeCleanupID: UUID = UUID()

    var progress: Double {
        guard totalSize > 0 else {
            return isFinished ? 1 : 0
        }
        return min(max(Double(deletedSize / totalSize), 0), 1)
    }

    func start(categoryName: String, totalSize: CGFloat) {
        activeCleanupID = UUID()
        self.categoryName = categoryName
        self.totalSize = max(totalSize, 0)
        deletedSize = 0
        currentDirectory = nil
        isFinished = false
        shouldDismiss = false
    }

    func setCategoryName(_ name: String) {
        categoryName = name
    }

    func update(
        currentDirectory: StorageSubCategoryEntity?,
        deletedSize: CGFloat,
        totalSize: CGFloat
    ) {
        self.currentDirectory = currentDirectory
        self.totalSize = max(totalSize, 0)
        self.deletedSize = min(max(deletedSize, 0), self.totalSize)
        shouldDismiss = false
    }

    func finish(isComplete: Bool) async {
        let cleanupID = activeCleanupID
        currentDirectory = nil

        if isComplete {
            deletedSize = totalSize
        }

        isFinished = true

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        await MainActor.run {
            guard self.activeCleanupID == cleanupID else {
                return
            }

            self.shouldDismiss = true
        }
    }
}
