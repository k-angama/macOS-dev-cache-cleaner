//
//  LoadStorageOverviewUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct LoadStorageOverviewUseCase {

    private let diskRepository: DiskRepository
    private let buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase
    private let refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase

    init(
        diskRepository: DiskRepository,
        buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase
    ) {
        self.diskRepository = diskRepository
        self.buildStorageCategoriesUseCase = buildStorageCategoriesUseCase
        self.refreshStorageCategoryUseCase = refreshStorageCategoryUseCase
    }

    func execute(homeURL: URL) -> AsyncStream<LoadStorageOverviewEventEntity> {
        AsyncStream { continuation in
            let task = Task {
                var categories = buildStorageCategoriesUseCase.execute()

                continuation.yield(
                    makeEvent(
                        phase: .started,
                        categories: categories
                    )
                )

                await withTaskGroup(of: (Int, StorageCategoryEntity)?.self) { group in
                    for (index, category) in categories.enumerated() {
                        group.addTask {
                            guard Task.isCancelled == false else {
                                return nil
                            }

                            let updatedCategory = await refreshStorageCategoryUseCase.execute(
                                homeURL: homeURL,
                                category: category
                            )

                            guard Task.isCancelled == false else {
                                return nil
                            }

                            return (index, updatedCategory)
                        }
                    }

                    for await result in group {
                        guard Task.isCancelled == false else {
                            group.cancelAll()
                            continuation.finish()
                            return
                        }

                        guard let (index, updatedCategory) = result else {
                            continue
                        }

                        categories[index] = updatedCategory

                        continuation.yield(
                            makeEvent(
                                phase: .categoryUpdated,
                                categories: categories,
                                updatedCategoryID: updatedCategory.id
                            )
                        )
                    }
                }

                continuation.yield(
                    makeEvent(
                        phase: .finished,
                        categories: categories
                    )
                )
                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    private func makeEvent(
        phase: LoadStorageOverviewEventEntity.Phase,
        categories: [StorageCategoryEntity],
        updatedCategoryID: UUID? = nil
    ) -> LoadStorageOverviewEventEntity {
        LoadStorageOverviewEventEntity(
            phase: phase,
            categories: categories,
            updatedCategoryID: updatedCategoryID,
            totalSize: diskRepository.totalDiskCapacity,
            freeSize: diskRepository.availableDiskCapacity
        )
    }
}
