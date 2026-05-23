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
    private var previousDeletedSize: CGFloat = 0
    private var previousTotalSize: CGFloat = 0
    private var displayAnimationTask: Task<Void, Never>?
    private let displayAnimationDuration: TimeInterval = 0.45
    private let displayAnimationFrameNanoseconds: UInt64 = 16_000_000
    
    var displayedDeletedSize: CGFloat = 0
    
    var progressPercentage: Int {
        Int((progress * 100).rounded())
    }

    var deletedSizeText: String {
        displayedDeletedSize.byteCountString
    }

    var realDeletedSizeText: String {
        store.deletedSize.byteCountString
    }

    var totalSizeText: String {
        store.totalSize.byteCountString
    }

    var realDeletedSize: CGFloat {
        store.deletedSize
    }

    var realTotalSize: CGFloat {
        store.totalSize
    }
    
    var currentDirectoryPath: String? {
        store.currentDirectory?.path
    }
    
    var progress: Double {
        guard store.totalSize > 0 else {
            return isFinished ? 1 : 0
        }

        return min(max(Double(displayedDeletedSize / store.totalSize), 0), 1)
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
        displayedDeletedSize = store.deletedSize
        previousDeletedSize = store.deletedSize
        previousTotalSize = store.totalSize
    }

    func setCategoryName(_ name: String) {
        store.setCategoryName(name)
    }

    func syncDisplayedProgress() {
        guard
            previousDeletedSize != store.deletedSize ||
            previousTotalSize != store.totalSize
        else {
            return
        }

        previousDeletedSize = store.deletedSize
        previousTotalSize = store.totalSize

        if store.deletedSize == 0 {
            displayAnimationTask?.cancel()
            displayedDeletedSize = 0
            return
        }

        animateDisplayedDeletedSize(to: store.deletedSize)
    }

    private func animateDisplayedDeletedSize(to targetDeletedSize: CGFloat) {
        displayAnimationTask?.cancel()

        let targetDeletedSize = min(max(targetDeletedSize, 0), store.totalSize)
        let startDeletedSize = displayedDeletedSize
        let distance = targetDeletedSize - startDeletedSize

        guard abs(distance) > 1 else {
            displayedDeletedSize = targetDeletedSize
            return
        }

        displayAnimationTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            let steps = max(Int(displayAnimationDuration / 0.016), 1)

            for step in 1...steps {
                guard Task.isCancelled == false else {
                    return
                }

                let linearProgress = Double(step) / Double(steps)
                let easedProgress = 1 - pow(1 - linearProgress, 3)
                self.displayedDeletedSize = startDeletedSize + (distance * CGFloat(easedProgress))

                try? await Task.sleep(nanoseconds: displayAnimationFrameNanoseconds)
            }

            guard Task.isCancelled == false else {
                return
            }

            self.displayedDeletedSize = targetDeletedSize
        }
    }
}
