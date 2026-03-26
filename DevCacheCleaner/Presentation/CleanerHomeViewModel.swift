//
//  ContentViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 09/03/2026.
//

import Foundation
import SwiftUI

@Observable
class CleanerHomeViewModel {
    
    // MARK: - Output
    
    var isAccessUserDirectory: Bool = false
    var totalSize: CGFloat = 0
    var freeSize: CGFloat = 0
    var categories: [StorageCategoryEntity] = []
    var categoryRowStates: [UUID: StorageCategoryRowState] = [:]
    var isAlertErrorRequest: Bool = false
    var alertErrorMessage: String = "No access directory"
    var isAlertNotHomeDirectory: Bool = false
    var isAlertCleanCache: Bool = false
    var storageCategorySelected: StorageCategoryEntity?
    var isCleaning: Bool = false
   
    
    // MARK: - Private property
    
    private let requestHomeAccessUseCase: RequestHomeAccessUseCase
    private let resolveHomeAccessUseCase: ResolveHomeAccessUseCase
    private let buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase
    private let observeDiskChangesUseCase: ObserveDiskChangesUseCase
    private let cleanStorageCategoryUseCase: CleanStorageCategoryUseCase
    private let cleanAllStorageCategoriesUseCase: CleanAllStorageCategoriesUseCase
    private let refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase
    private let loadStorageOverviewUseCase: LoadStorageOverviewUseCase
    private let readDiskSpaceUseCase: ReadDiskSpaceUseCase
    private let cleanupProgressStore: CleanupProgressStore
    
    
    init(
        requestHomeAccessUseCase: RequestHomeAccessUseCase,
        resolveHomeAccessUseCase: ResolveHomeAccessUseCase,
        buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase,
        observeDiskChangesUseCase: ObserveDiskChangesUseCase,
        cleanStorageCategoryUseCase: CleanStorageCategoryUseCase,
        cleanAllStorageCategoriesUseCase: CleanAllStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase,
        loadStorageOverviewUseCase: LoadStorageOverviewUseCase,
        readDiskSpaceUseCase: ReadDiskSpaceUseCase,
        cleanupProgressStore: CleanupProgressStore
    ) {
        self.requestHomeAccessUseCase = requestHomeAccessUseCase
        self.resolveHomeAccessUseCase = resolveHomeAccessUseCase
        self.buildStorageCategoriesUseCase = buildStorageCategoriesUseCase
        self.observeDiskChangesUseCase = observeDiskChangesUseCase
        self.cleanStorageCategoryUseCase = cleanStorageCategoryUseCase
        self.cleanAllStorageCategoriesUseCase = cleanAllStorageCategoriesUseCase
        self.refreshStorageCategoryUseCase = refreshStorageCategoryUseCase
        self.loadStorageOverviewUseCase = loadStorageOverviewUseCase
        self.readDiskSpaceUseCase = readDiskSpaceUseCase
        self.cleanupProgressStore = cleanupProgressStore
        setup()
    }
    
    // MARK: - Public Methode
    
    func requesUserDirectoryAccess() {
        isAlertErrorRequest = false

        if let url = requestHomeAccessUseCase.execute() {
            isAccessUserDirectory = true
            Task { [weak self] in
                await self?.loadStorageOverview(homeURL: url)
            }
        } else {
            alertErrorMessage = "Unable to access the selected directory."
            isAlertErrorRequest = true
        }
    }
    
    func resolveHomeURL() {
        if let homeURL = resolveHomeAccessUseCase.execute() {
            isAccessUserDirectory = true
            Task { [weak self] in
                await self?.loadStorageOverview(homeURL: homeURL)
            }
        } else {
            isAccessUserDirectory = false
        }
        
    }
    
    func askRemoveDirectory(entiy: StorageCategoryEntity) {
        guard isCleaning == false else {
            return
        }
        isAlertCleanCache = true
        storageCategorySelected = entiy
    }

    func askRemoveAllCaches() {
        guard isCleaning == false else {
            return
        }
        isAlertCleanCache = true
        storageCategorySelected = nil
    }

    func startCleanup() -> String? {
        if storageCategorySelected == nil {
            return startCleanupForAllCategories()
        }

        return startCleanupForSelectedCategory()
    }

    func startCleanupForSelectedCategory() -> String? {
        guard
            isCleaning == false,
            let selectedCategoryID = storageCategorySelected?.id,
            let entity = categories.first(where: { $0.id == selectedCategoryID })
        else {
            return nil
        }

        guard let homeURL = resolveHomeAccessUseCase.execute() else {
            alertErrorMessage = "Unable to access your Home directory."
            isAlertErrorRequest = true
            return nil
        }

        isCleaning = true
        storageCategorySelected = entity
        setCategoryRowState(.deleting, for: entity.id)
        cleanupProgressStore.start(
            categoryName: entity.name,
            totalSize: entity.categories.reduce(0) { $0 + $1.size }
        )

        Task { [weak self] in
            await self?.performCleanup(of: entity, homeURL: homeURL)
        }

        return entity.name
    }

    func startCleanupForAllCategories() -> String? {
        guard isCleaning == false else {
            return nil
        }

        let categoriesToClean = categories.filter { $0.size > 0.01 }

        guard categoriesToClean.isEmpty == false else {
            return nil
        }

        guard let homeURL = resolveHomeAccessUseCase.execute() else {
            alertErrorMessage = "Unable to access your Home directory."
            isAlertErrorRequest = true
            return nil
        }

        isCleaning = true
        storageCategorySelected = nil
        cleanupProgressStore.start(
            categoryName: "All Caches",
            totalSize: categoriesToClean.reduce(0) { $0 + $1.size }
        )

        Task { [weak self] in
            await self?.performCleanup(of: categoriesToClean, homeURL: homeURL)
        }

        return "All Caches"
    }
    
    func startMonitoring() {
        if let homeURL = resolveHomeAccessUseCase.execute() {
            observeDiskChangesUseCase.start(url: homeURL) { [weak self] path in
                self?.handleChanges(path)
            }
        }
    }
    
    func stopMonitoring() {
        observeDiskChangesUseCase.stop()
    }
    
    
    // MARK: - Private Methode
    
    private func setup() {
        categories = buildStorageCategoriesUseCase.execute()
        categoryRowStates.removeAll()
        resolveHomeURL()
        updateDiskSpace()
    }

    @MainActor
    private func performCleanup(of entity: StorageCategoryEntity, homeURL: URL) async {
        var didFinish = false

        for await event in cleanStorageCategoryUseCase.execute(homeURL: homeURL, category: entity) {
            applyCleanupEvent(event, categoryID: entity.id)

            if event.phase == .finished {
                didFinish = true
                storageCategorySelected = nil
                isCleaning = false
                setCategoryRowState(.ready, for: entity.id)

                if event.failedDirectories.isEmpty == false {
                    alertErrorMessage = "Some cache directories could not be deleted."
                    isAlertErrorRequest = true
                }

                await cleanupProgressStore.finish(isComplete: event.didCompleteFully)
            }
        }

        if didFinish == false {
            storageCategorySelected = nil
            isCleaning = false
            setCategoryRowState(.ready, for: entity.id)
        }
    }

    @MainActor
    private func performCleanup(of categoriesToClean: [StorageCategoryEntity], homeURL: URL) async {
        let totalCleanupSize = categoriesToClean.reduce(0) { $0 + $1.size }
        let categoryIDs = Set(categoriesToClean.map(\.id))
        var deletedSizeOffset: CGFloat = 0
        var failedDirectories: [StorageSubCategoryEntity] = []
        var finishedCategoryCount = 0

        for await event in cleanAllStorageCategoriesUseCase.execute(
            homeURL: homeURL,
            categories: categoriesToClean
        ) {
            guard let updatedCategory = event.updatedCategory else {
                continue
            }

            if event.phase == .started {
                setCategoryRowState(.deleting, for: updatedCategory.id)
            }

            applyCleanupEvent(
                event,
                categoryID: updatedCategory.id,
                deletedSizeOffset: deletedSizeOffset,
                totalProgressSize: totalCleanupSize
            )

            if event.phase == .finished {
                finishedCategoryCount += 1
                deletedSizeOffset = min(totalCleanupSize, deletedSizeOffset + event.deletedSize)
                failedDirectories.append(contentsOf: event.failedDirectories)
                setCategoryRowState(.ready, for: updatedCategory.id)
            }
        }

        storageCategorySelected = nil
        isCleaning = false

        if finishedCategoryCount == categoriesToClean.count {
            if failedDirectories.isEmpty == false {
                alertErrorMessage = "Some cache directories could not be deleted."
                isAlertErrorRequest = true
            }

            await cleanupProgressStore.finish(isComplete: failedDirectories.isEmpty)
            return
        }

        for categoryID in categoryIDs {
            setCategoryRowState(.ready, for: categoryID)
        }
    }
    
    private func handleChanges(_ path: String) {
        updateDiskSpace()

        guard
            let homeURL = resolveHomeAccessUseCase.execute(),
            let categoryIndex = categoryIndex(containing: path)
        else {
            return
        }

        Task { [weak self] in
            await self?.refreshCategory(at: categoryIndex, homeURL: homeURL)
        }
    }
    
    private func refreshCategory(at index: Int, homeURL: URL) async {
        guard categories.indices.contains(index) else {
            return
        }

        let category = categories[index]
        let categoryID = category.id

        let updatedCategory = await refreshStorageCategoryUseCase.execute(
            homeURL: homeURL,
            category: category
        )
        updateCategory(updatedCategory, for: categoryID)

    }

    private func categoryIndex(containing path: String) -> Int? {
        categories.firstIndex { category in
            category.categories.contains(where: { path.contains($0.path) })
        }
    }

    private func applyCleanupEvent(
        _ event: CleanStorageCategoryEventEntity,
        categoryID: UUID,
        deletedSizeOffset: CGFloat = 0,
        totalProgressSize: CGFloat? = nil
    ) {
        let progressTotalSize = max(totalProgressSize ?? event.totalSize, 0)
        let progressDeletedSize = min(
            progressTotalSize,
            max(deletedSizeOffset + event.deletedSize, 0)
        )

        cleanupProgressStore.setCategoryName(event.categoryName)
        cleanupProgressStore.update(
            currentDirectory: event.currentDirectory,
            deletedSize: progressDeletedSize,
            totalSize: progressTotalSize
        )

        if let updatedCategory = event.updatedCategory {
            updateCategory(updatedCategory, for: categoryID)
        }

        if let totalDiskCapacity = event.totalDiskCapacity {
            totalSize = totalDiskCapacity
        }

        if let availableDiskCapacity = event.availableDiskCapacity {
            freeSize = availableDiskCapacity
        }
    }

    private func updateCategory(_ updatedCategory: StorageCategoryEntity, for id: UUID) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            return
        }

        categories[index] = updatedCategory
    }
    
    private func setCategoryRowState(_ state: StorageCategoryRowState, for id: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            categoryRowStates[id] = state
        }
    }

    private func setAllCategoryRowStates(_ state: StorageCategoryRowState) {
        withAnimation(.easeInOut(duration: 0.2)) {
            categoryRowStates = Dictionary(
                uniqueKeysWithValues: categories.map { ($0.id, state) }
            )
        }
    }

    @MainActor
    private func loadStorageOverview(homeURL: URL) async {
        setAllCategoryRowStates(.loading)

        let overview = await loadStorageOverviewUseCase.execute(homeURL: homeURL)
        categories = overview.categories
        totalSize = overview.totalSize
        freeSize = overview.freeSize
        setAllCategoryRowStates(.ready)
    }

    private func updateDiskSpace() {
        let diskSpace = readDiskSpaceUseCase.execute()
        totalSize = diskSpace.totalSize
        freeSize = diskSpace.freeSize
    }
    
}
