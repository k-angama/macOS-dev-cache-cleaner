//
//  CleanAllStorageCategoriesUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct CleanAllStorageCategoriesUseCase {

    private let cleanStorageCategoryUseCase: CleanStorageCategoryUseCase

    init(cleanStorageCategoryUseCase: CleanStorageCategoryUseCase) {
        self.cleanStorageCategoryUseCase = cleanStorageCategoryUseCase
    }

    func execute(
        homeURL: URL,
        categories: [StorageCategoryEntity]
    ) -> AsyncStream<CleanStorageCategoryEventEntity> {
        AsyncStream { continuation in
            let task = Task {
                for category in categories {
                    guard Task.isCancelled == false else {
                        continuation.finish()
                        return
                    }

                    let categoryEvents = cleanStorageCategoryUseCase.execute(
                        homeURL: homeURL,
                        category: category
                    )

                    for await event in categoryEvents {
                        guard Task.isCancelled == false else {
                            continuation.finish()
                            return
                        }

                        continuation.yield(event)
                    }
                }

                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
