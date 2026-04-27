//
//  ContentViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 09/03/2026.
//

import Foundation
import Observation
import SwiftUI

@Observable
class CleanerHomeViewModel {

    // MARK: - Output

    var isAccessUserDirectory: Bool = false
    var totalSize: CGFloat = 0
    var freeSize: CGFloat = 0
    var categories: [StorageCategoryEntity] = [] {
        didSet {
            syncSelectedCategoryForDetails()
        }
    }
    var categoryRowStates: [UUID: StorageCategoryRowState] = [:]
    var isAlertErrorRequest: Bool = false
    var alertErrorMessage: String = "No access directory"
    var isCleaning: Bool = false {
        didSet {
            guard oldValue, isCleaning == false, hasPendingWorkspaceSelectionSync else {
                return
            }

            hasPendingWorkspaceSelectionSync = false
            syncWorkspaceSelectionFromSettingsStore()
        }
    }
    var selectedWorkspaceName: String?
    var selectedWorkspacePath: String?
    var selectedWorkspaceCategory: StorageCategoryEntity? {
        didSet {
            syncSelectedWorkspaceCategoryForDetails()
        }
    }
    var workspaceRowState: StorageCategoryRowState = .ready
    var cleanAllWorkspaceOptionTitle: String? {
        guard
            storageCategorySelected == nil,
            isWorkspaceCleanupSelected == false,
            workspaceRowState == .ready,
            let selectedWorkspaceName,
            let selectedWorkspaceCategory,
            selectedWorkspaceCategory.size > 0.01
        else {
            return nil
        }

        return "Also clean selected workspace: \(selectedWorkspaceName) (\(selectedWorkspaceCategory.size.byteCountString))"
    }

    // MARK: - Input

    var isAlertCleanCache: Bool = false
    var selectedCategoryForDetails: StorageCategoryEntity?
    var selectedWorkspaceCategoryForDetails: StorageCategoryEntity?

    // MARK: - ViewModel State

    private(set) var storageCategorySelected: StorageCategoryEntity?
    private var selectedWorkspaceURL: URL?
    private var isWorkspaceCleanupSelected = false
    private var hasPendingWorkspaceSelectionSync = false

    // MARK: - UseCase

    private let saveHomeAccessUseCase: SaveHomeAccessUseCase
    private let resolveHomeAccessUseCase: ResolveHomeAccessUseCase
    private let buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase
    private let observeDiskChangesUseCase: ObserveDiskChangesUseCase
    private let cleanStorageCategoryUseCase: CleanStorageCategoryUseCase
    private let cleanAllStorageCategoriesUseCase: CleanAllStorageCategoriesUseCase
    private let refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase
    private let loadStorageOverviewUseCase: LoadStorageOverviewUseCase
    private let loadWorkspaceCleanupCategoryUseCase: LoadWorkspaceCleanupCategoryUseCase
    private let settingsStore: SettingsStore
    private let saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase
    private let resolveWorkspaceAccessUseCase: ResolveWorkspaceAccessUseCase
    private let readDiskSpaceUseCase: ReadDiskSpaceUseCase
    
    // MARK: - Store
    
    private let cleanupProgressStore: CleanupProgressStore

    // MARK: - Init

    init(
        saveHomeAccessUseCase: SaveHomeAccessUseCase,
        resolveHomeAccessUseCase: ResolveHomeAccessUseCase,
        buildStorageCategoriesUseCase: BuildStorageCategoriesUseCase,
        observeDiskChangesUseCase: ObserveDiskChangesUseCase,
        cleanStorageCategoryUseCase: CleanStorageCategoryUseCase,
        cleanAllStorageCategoriesUseCase: CleanAllStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: RefreshStorageCategoryUseCase,
        loadStorageOverviewUseCase: LoadStorageOverviewUseCase,
        loadWorkspaceCleanupCategoryUseCase: LoadWorkspaceCleanupCategoryUseCase,
        settingsStore: SettingsStore,
        saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase,
        resolveWorkspaceAccessUseCase: ResolveWorkspaceAccessUseCase,
        readDiskSpaceUseCase: ReadDiskSpaceUseCase,
        cleanupProgressStore: CleanupProgressStore
    ) {
        self.saveHomeAccessUseCase = saveHomeAccessUseCase
        self.resolveHomeAccessUseCase = resolveHomeAccessUseCase
        self.buildStorageCategoriesUseCase = buildStorageCategoriesUseCase
        self.observeDiskChangesUseCase = observeDiskChangesUseCase
        self.cleanStorageCategoryUseCase = cleanStorageCategoryUseCase
        self.cleanAllStorageCategoriesUseCase = cleanAllStorageCategoriesUseCase
        self.refreshStorageCategoryUseCase = refreshStorageCategoryUseCase
        self.loadStorageOverviewUseCase = loadStorageOverviewUseCase
        self.loadWorkspaceCleanupCategoryUseCase = loadWorkspaceCleanupCategoryUseCase
        self.settingsStore = settingsStore
        self.saveWorkspaceAccessUseCase = saveWorkspaceAccessUseCase
        self.resolveWorkspaceAccessUseCase = resolveWorkspaceAccessUseCase
        self.readDiskSpaceUseCase = readDiskSpaceUseCase
        self.cleanupProgressStore = cleanupProgressStore
        setup()
    }

    // MARK: - Access

    func selectHomeSpace(url: URL?) {
        guard let url else {
            return
        }

        if saveHomeAccessUseCase.execute(url: url) == false {
            alertErrorMessage = "Unable to access the selected directory."
            isAlertErrorRequest = true
        } else {
            isAccessUserDirectory = true
            Task { [weak self] in
                await self?.loadStorageOverview(homeURL: url)
            }
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

    // MARK: - Workspace Selection

    func selectWorkspace(url: URL?) {
        guard let url else {
            return
        }

        if saveWorkspaceAccessUseCase.execute(url: url) == false {
            alertErrorMessage = "Unable to save workspace access."
            isAlertErrorRequest = true
            return
        }

        settingsStore.selectedWorkspaceURL = url
        applyWorkspaceSelection(url)
    }

    private func applyWorkspaceSelection(_ url: URL) {
        guard selectedWorkspaceURL?.path != url.path else {
            return
        }

        selectedWorkspaceName = url.lastPathComponent
        selectedWorkspacePath = url.path
        selectedWorkspaceURL = url
        selectedWorkspaceCategory = StorageCategoryEntity(
            name: "Workspace: \(url.lastPathComponent)",
            color: .teal,
            size: 0,
            categories: []
        )
        workspaceRowState = .loading

        Task { [weak self] in
            await self?.loadWorkspaceCleanupCategory(workspaceURL: url)
        }
    }

    // MARK: - Cleanup Actions

    func askRemoveDirectory(entity: StorageCategoryEntity) {
        guard isCleaning == false else {
            return
        }
        isAlertCleanCache = true
        storageCategorySelected = entity
        isWorkspaceCleanupSelected = false
    }

    func askRemoveAllCaches() {
        guard isCleaning == false else {
            return
        }
        isAlertCleanCache = true
        storageCategorySelected = nil
        isWorkspaceCleanupSelected = false
    }

    func askRemoveWorkspaceCaches() {
        guard
            isCleaning == false,
            workspaceRowState == .ready,
            let selectedWorkspaceCategory,
            selectedWorkspaceCategory.size > 0.01
        else {
            return
        }

        isAlertCleanCache = true
        storageCategorySelected = selectedWorkspaceCategory
        isWorkspaceCleanupSelected = true
    }

    func startCleanup(includeWorkspaceInAllCaches: Bool = false) -> String? {
        if isWorkspaceCleanupSelected {
            return startCleanupForWorkspace()
        }

        if storageCategorySelected == nil {
            return startCleanupForAllCategories(
                includeWorkspace: includeWorkspaceInAllCaches
            )
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

    func startCleanupForAllCategories(includeWorkspace: Bool = false) -> String? {
        guard isCleaning == false else {
            return nil
        }

        let categoriesToClean = categories.filter { $0.size > 0.01 }
        let workspaceCleanup = workspaceCleanupForCleanAll(isIncluded: includeWorkspace)

        guard categoriesToClean.isEmpty == false || workspaceCleanup != nil else {
            return nil
        }

        guard let homeURL = resolveHomeAccessUseCase.execute() else {
            alertErrorMessage = "Unable to access your Home directory."
            isAlertErrorRequest = true
            return nil
        }

        isCleaning = true
        storageCategorySelected = nil
        let cleanupName = workspaceCleanup == nil ? "All Caches" : "All Caches + Workspace"
        let categoriesCleanupSize = categoriesToClean.reduce(0) { $0 + $1.size }
        let workspaceCleanupSize = workspaceCleanup?.category.size ?? 0

        cleanupProgressStore.start(
            categoryName: cleanupName,
            totalSize: categoriesCleanupSize + workspaceCleanupSize
        )

        Task { [weak self] in
            await self?.performCleanup(
                of: categoriesToClean,
                homeURL: homeURL,
                workspaceCleanup: workspaceCleanup
            )
        }

        return cleanupName
    }

    func startCleanupForWorkspace() -> String? {
        guard
            isCleaning == false,
            let selectedWorkspaceURL,
            let selectedWorkspaceCategory,
            selectedWorkspaceCategory.size > 0.01
        else {
            return nil
        }

        isCleaning = true
        storageCategorySelected = selectedWorkspaceCategory
        workspaceRowState = .deleting
        cleanupProgressStore.start(
            categoryName: selectedWorkspaceCategory.name,
            totalSize: selectedWorkspaceCategory.categories.reduce(0) { $0 + $1.size }
        )

        Task { [weak self] in
            await self?.performWorkspaceCleanup(
                of: selectedWorkspaceCategory,
                workspaceURL: selectedWorkspaceURL
            )
        }

        return selectedWorkspaceCategory.name
    }

    private func workspaceCleanupForCleanAll(
        isIncluded: Bool
    ) -> (category: StorageCategoryEntity, workspaceURL: URL)? {
        guard
            isIncluded,
            workspaceRowState == .ready,
            let selectedWorkspaceURL,
            let selectedWorkspaceCategory,
            selectedWorkspaceCategory.size > 0.01
        else {
            return nil
        }

        return (selectedWorkspaceCategory, selectedWorkspaceURL)
    }

    // MARK: - Monitoring

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

    // MARK: - Details Selection

    func selectCategoryForDetails(_ category: StorageCategoryEntity) {
        selectedCategoryForDetails = category
        syncSelectedCategoryForDetails()
    }

    func selectWorkspaceForDetails() {
        selectedWorkspaceCategoryForDetails = selectedWorkspaceCategory
    }

    // MARK: - Setup

    private func setup() {
        categories = buildStorageCategoriesUseCase.execute()
        categoryRowStates.removeAll()
        resolveHomeURL()
        resolveWorkspaceURL()
        observeSettingsStore()
        updateDiskSpace()
    }

    // MARK: - Loading

    @MainActor
    private func loadStorageOverview(homeURL: URL) async {
        for await event in loadStorageOverviewUseCase.execute(homeURL: homeURL) {
            applyLoadStorageOverviewEvent(event)
        }
    }

    private func applyLoadStorageOverviewEvent(_ event: LoadStorageOverviewEventEntity) {
        categories = event.categories
        totalSize = event.totalSize
        freeSize = event.freeSize

        switch event.phase {
        case .started:
            setAllCategoryRowStates(.loading)
        case .categoryUpdated:
            if let updatedCategoryID = event.updatedCategoryID {
                setCategoryRowState(.ready, for: updatedCategoryID)
            }
        case .finished:
            setAllCategoryRowStates(.ready)
        }
    }

    @MainActor
    private func loadWorkspaceCleanupCategory(workspaceURL: URL) async {
        let category = await loadWorkspaceCleanupCategoryUseCase.execute(
            workspaceURL: workspaceURL
        )

        guard selectedWorkspaceURL?.path == workspaceURL.path else {
            return
        }

        selectedWorkspaceCategory = category
        workspaceRowState = .ready
    }

    private func resolveWorkspaceURL() {
        guard let workspaceURL = settingsStore.selectedWorkspaceURL
                ?? resolveWorkspaceAccessUseCase.execute()
        else {
            return
        }

        settingsStore.selectedWorkspaceURL = workspaceURL
        applyWorkspaceSelection(workspaceURL)
    }

    private func syncWorkspaceSelectionFromSettingsStore() {
        guard let workspaceURL = settingsStore.selectedWorkspaceURL else {
            return
        }

        applyWorkspaceSelection(workspaceURL)
    }

    private func observeSettingsStore() {
        withObservationTracking {
            _ = settingsStore.selectedWorkspaceURL
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.handleSettingsStoreChange()
                self?.observeSettingsStore()
            }
        }
    }

    @MainActor
    private func handleSettingsStoreChange() {
        guard let workspaceURL = settingsStore.selectedWorkspaceURL else {
            return
        }

        guard selectedWorkspaceURL?.path != workspaceURL.path else {
            return
        }

        guard isCleaning == false else {
            hasPendingWorkspaceSelectionSync = true
            return
        }

        applyWorkspaceSelection(workspaceURL)
    }

    private func updateDiskSpace() {
        let diskSpace = readDiskSpaceUseCase.execute()
        totalSize = diskSpace.totalSize
        freeSize = diskSpace.freeSize
    }

    // MARK: - Cleanup Execution

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
    private func performCleanup(
        of categoriesToClean: [StorageCategoryEntity],
        homeURL: URL,
        workspaceCleanup: (category: StorageCategoryEntity, workspaceURL: URL)? = nil
    ) async {
        let categoriesCleanupSize = categoriesToClean.reduce(0) { $0 + $1.size }
        let workspaceCleanupSize = workspaceCleanup?.category.size ?? 0
        let totalCleanupSize = categoriesCleanupSize + workspaceCleanupSize
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

        guard finishedCategoryCount == categoriesToClean.count else {
            storageCategorySelected = nil
            isCleaning = false

            for categoryID in categoryIDs {
                setCategoryRowState(.ready, for: categoryID)
            }
            return
        }

        if let workspaceCleanup {
            var didFinishWorkspace = false
            workspaceRowState = .deleting

            for await event in cleanStorageCategoryUseCase.execute(
                homeURL: workspaceCleanup.workspaceURL,
                category: workspaceCleanup.category
            ) {
                applyCleanupEvent(
                    event,
                    categoryID: workspaceCleanup.category.id,
                    deletedSizeOffset: deletedSizeOffset,
                    totalProgressSize: totalCleanupSize,
                    onCategoryUpdated: { [weak self] updatedCategory in
                        self?.selectedWorkspaceCategory = updatedCategory
                    }
                )

                if event.phase == .finished {
                    didFinishWorkspace = true
                    deletedSizeOffset = min(totalCleanupSize, deletedSizeOffset + event.deletedSize)
                    failedDirectories.append(contentsOf: event.failedDirectories)
                    workspaceRowState = .ready
                }
            }

            if didFinishWorkspace == false {
                workspaceRowState = .ready
                storageCategorySelected = nil
                isCleaning = false
                return
            }
        }

        storageCategorySelected = nil
        isCleaning = false

        if failedDirectories.isEmpty == false {
            alertErrorMessage = "Some cache directories could not be deleted."
            isAlertErrorRequest = true
        }

        await cleanupProgressStore.finish(isComplete: failedDirectories.isEmpty)
    }

    @MainActor
    private func performWorkspaceCleanup(of entity: StorageCategoryEntity, workspaceURL: URL) async {
        var didFinish = false

        for await event in cleanStorageCategoryUseCase.execute(homeURL: workspaceURL, category: entity) {
            applyCleanupEvent(
                event,
                categoryID: entity.id,
                onCategoryUpdated: { [weak self] updatedCategory in
                    self?.selectedWorkspaceCategory = updatedCategory
                }
            )

            if event.phase == .finished {
                didFinish = true
                storageCategorySelected = nil
                isWorkspaceCleanupSelected = false
                isCleaning = false
                workspaceRowState = .ready

                if event.failedDirectories.isEmpty == false {
                    alertErrorMessage = "Some workspace directories could not be deleted."
                    isAlertErrorRequest = true
                }

                await cleanupProgressStore.finish(isComplete: event.didCompleteFully)
            }
        }

        if didFinish == false {
            storageCategorySelected = nil
            isWorkspaceCleanupSelected = false
            isCleaning = false
            workspaceRowState = .ready
        }
    }

    private func applyCleanupEvent(
        _ event: CleanStorageCategoryEventEntity,
        categoryID: UUID,
        deletedSizeOffset: CGFloat = 0,
        totalProgressSize: CGFloat? = nil,
        onCategoryUpdated: ((StorageCategoryEntity) -> Void)? = nil
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
            if let onCategoryUpdated {
                onCategoryUpdated(updatedCategory)
            } else {
                updateCategory(updatedCategory, for: categoryID)
            }
        }

        if let totalDiskCapacity = event.totalDiskCapacity {
            totalSize = totalDiskCapacity
        }

        if let availableDiskCapacity = event.availableDiskCapacity {
            freeSize = availableDiskCapacity
        }
    }

    // MARK: - Monitoring Updates

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

    // MARK: - State Updates

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

    private func syncSelectedCategoryForDetails() {
        guard let selectedCategoryForDetails else {
            return
        }

        self.selectedCategoryForDetails = categories.first {
            $0.name == selectedCategoryForDetails.name
        }
    }

    private func syncSelectedWorkspaceCategoryForDetails() {
        guard selectedWorkspaceCategoryForDetails != nil else {
            return
        }

        selectedWorkspaceCategoryForDetails = selectedWorkspaceCategory
    }
}
