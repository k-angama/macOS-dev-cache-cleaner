//
//  CleanStorageCategoryUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct CleanStorageCategoryUseCase {

    private let diskRepository: DiskRepository

    init(diskRepository: DiskRepository) {
        self.diskRepository = diskRepository
    }

    func execute(
        homeURL: URL,
        category: StorageCategoryEntity
    ) -> AsyncStream<CleanStorageCategoryEventEntity> {
        AsyncStream { continuation in
            let task = Task {
                var updatedCategory = await refreshCategory(homeURL: homeURL, category: category)
                let totalSize = updatedCategory.size
                var deletedSize: CGFloat = 0
                var failedDirectories: [StorageSubCategoryEntity] = []

                continuation.yield(
                    makeEvent(
                        phase: .started,
                        categoryName: category.name,
                        currentDirectory: nil,
                        updatedCategory: updatedCategory,
                        deletedSize: deletedSize,
                        totalSize: totalSize,
                        failedDirectories: failedDirectories,
                        totalDiskCapacity: nil,
                        availableDiskCapacity: nil
                    )
                )

                for index in updatedCategory.categories.indices {
                    guard Task.isCancelled == false else {
                        continuation.finish()
                        return
                    }

                    let subCategory = updatedCategory.categories[index]

                    continuation.yield(
                        makeEvent(
                            phase: .deletingDirectory,
                            categoryName: category.name,
                            currentDirectory: subCategory,
                            updatedCategory: updatedCategory,
                            deletedSize: deletedSize,
                            totalSize: totalSize,
                            failedDirectories: failedDirectories,
                            totalDiskCapacity: nil,
                            availableDiskCapacity: nil
                        )
                    )

                    var deletedSizeForCurrentSubcategory: CGFloat = 0
                    var failedLocations: [StorageLocationEntity] = []

                    for location in subCategory.locations {
                        guard Task.isCancelled == false else {
                            continuation.finish()
                            return
                        }

                        do {
                            try await diskRepository.cleanPath(
                                homeURL: homeURL,
                                path: location.path,
                                rule: location.rule,
                                expectedDeletedSize: location.size,
                                onFileDeleted: { deletedFileSize in
                                    deletedSizeForCurrentSubcategory += deletedFileSize
                                    continuation.yield(
                                        makeEvent(
                                            phase: .progressUpdated,
                                            categoryName: category.name,
                                            currentDirectory: subCategory,
                                            updatedCategory: updatedCategory,
                                            deletedSize: min(
                                                totalSize,
                                                deletedSize + deletedSizeForCurrentSubcategory
                                            ),
                                            totalSize: totalSize,
                                            failedDirectories: failedDirectories,
                                            totalDiskCapacity: nil,
                                            availableDiskCapacity: nil
                                        )
                                    )
                                }
                            )
                        } catch DiskManagerError.directoryDoesNotExist {
                        } catch {
                            failedLocations.append(location)
                        }
                    }

                    if failedLocations.isEmpty == false {
                        failedDirectories.append(
                            subCategory.updateLocations(failedLocations)
                        )
                    }

                    let refreshedSubCategory = await refreshSubcategory(
                        homeURL: homeURL,
                        subCategory: subCategory
                    )

                    updatedCategory = updatedCategory
                        .updateCategory(index: index, subCategory: refreshedSubCategory)
                        .updateSize()
                    deletedSize = min(totalSize, max(totalSize - updatedCategory.size, 0))

                    continuation.yield(
                        makeEvent(
                            phase: .progressUpdated,
                            categoryName: category.name,
                            currentDirectory: refreshedSubCategory,
                            updatedCategory: updatedCategory,
                            deletedSize: deletedSize,
                            totalSize: totalSize,
                            failedDirectories: failedDirectories,
                            totalDiskCapacity: nil,
                            availableDiskCapacity: nil
                        )
                    )
                }

                continuation.yield(
                    makeEvent(
                        phase: .finished,
                        categoryName: category.name,
                        currentDirectory: nil,
                        updatedCategory: updatedCategory,
                        deletedSize: deletedSize,
                        totalSize: totalSize,
                        failedDirectories: failedDirectories,
                        totalDiskCapacity: diskRepository.totalDiskCapacity,
                        availableDiskCapacity: diskRepository.availableDiskCapacity
                    )
                )
                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    private func refreshCategory(
        homeURL: URL,
        category: StorageCategoryEntity
    ) async -> StorageCategoryEntity {
        var updatedCategory = category

        for (index, subCategory) in category.categories.enumerated() {
            guard Task.isCancelled == false else {
                return updatedCategory
            }

            let refreshedSubCategory = await refreshSubcategory(
                homeURL: homeURL,
                subCategory: subCategory
            )

            updatedCategory = updatedCategory
                .updateCategory(index: index, subCategory: refreshedSubCategory)
                .updateSize()
        }

        return updatedCategory
    }

    private func refreshSubcategory(
        homeURL: URL,
        subCategory: StorageSubCategoryEntity
    ) async -> StorageSubCategoryEntity {
        var updatedLocations: [StorageLocationEntity] = []

        for location in subCategory.locations {
            guard Task.isCancelled == false else {
                return subCategory.updateLocations(updatedLocations)
            }

            let size = await diskRepository.computeDiskSize(
                homeURL: homeURL,
                path: location.path,
                rule: location.rule
            )
            updatedLocations.append(location.updateSize(size))
        }

        return subCategory.updateLocations(updatedLocations)
    }

    private func makeEvent(
        phase: CleanStorageCategoryEventEntity.Phase,
        categoryName: String,
        currentDirectory: StorageSubCategoryEntity?,
        updatedCategory: StorageCategoryEntity?,
        deletedSize: CGFloat,
        totalSize: CGFloat,
        failedDirectories: [StorageSubCategoryEntity],
        totalDiskCapacity: CGFloat?,
        availableDiskCapacity: CGFloat?
    ) -> CleanStorageCategoryEventEntity {
        CleanStorageCategoryEventEntity(
            phase: phase,
            categoryName: categoryName,
            currentDirectory: currentDirectory,
            updatedCategory: updatedCategory,
            deletedSize: deletedSize,
            totalSize: totalSize,
            failedDirectories: failedDirectories,
            totalDiskCapacity: totalDiskCapacity,
            availableDiskCapacity: availableDiskCapacity
        )
    }
}
