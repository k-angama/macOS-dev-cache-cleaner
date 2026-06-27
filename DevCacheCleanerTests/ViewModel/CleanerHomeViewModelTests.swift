import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct CleanerHomeViewModelTests {

    @Test func selectHomeSpace_whenGranted_marksAccessAndLoadsOverview() async {
        let context = makeSUT(totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.viewModel.selectHomeSpace(url: testHomeURL)

        let didLoadOverview = await waitUntil {
            context.viewModel.isAccessUserDirectory &&
            context.viewModel.categoryRowStates.count == context.viewModel.categories.count &&
            context.viewModel.categoryRowStates.values.allSatisfy { $0 == .ready }
        }

        #expect(didLoadOverview)
        #expect(context.homeAccessRepository.saveCallCount == 1)
        #expect(context.homeAccessRepository.savedURL == testHomeURL)
        #expect(context.viewModel.isAccessUserDirectory)
        #expect(context.viewModel.totalSize == 500)
        #expect(context.viewModel.freeSize == 200)
        #expect(context.viewModel.isAlertErrorRequest == false)
    }

    @Test func selectHomeSpace_whenSavingFails_showsErrorAlert() {
        let context = makeSUT(shouldSaveHomeURL: false)

        context.viewModel.selectHomeSpace(url: testHomeURL)

        #expect(context.homeAccessRepository.saveCallCount == 1)
        #expect(context.homeAccessRepository.savedURL == testHomeURL)
        #expect(context.viewModel.isAccessUserDirectory == false)
        #expect(context.viewModel.isAlertErrorRequest)
        #expect(context.viewModel.alertErrorMessage == "Unable to access the selected directory.")
    }

    @Test func startCleanup_forSelectedCategory_updatesCategoryAndResetsState() async {
        let category = makeCategory(
            name: "Flutter",
            subcategories: [makeSubCategory(name: ".pub-cache", size: 2.5)]
        )
        let context = makeSUT(totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.diskRepository.setComputeResponses([2.5, 0], for: ".pub-cache")
        context.viewModel.categories = [category]

        context.viewModel.askRemoveDirectory(entity: category)
        let cleanupName = context.viewModel.startCleanup()

        let didFinishCleanup = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            abs(context.viewModel.categories[0].size - 0) < 0.0001 &&
            context.viewModel.categoryRowStates[category.id] == .ready &&
            context.cleanupProgressStore.isFinished
        }

        #expect(cleanupName == "Flutter")
        #expect(didFinishCleanup)
        #expect(context.viewModel.storageCategorySelected == nil)
        #expect(context.cleanupProgressStore.categoryName == "Flutter")
        #expect(context.diskRepository.cleanedPaths == [
            context.diskRepository.key(path: ".pub-cache")
        ])
    }

    @Test func startCleanup_forSelectedLocation_preservesUnselectedSibling() async {
        let selectedLocation = StorageLocationEntity(
            path: "Cache/Selected",
            rule: .allContents,
            size: 2
        )
        let unselectedLocation = StorageLocationEntity(
            path: "Cache/Kept",
            rule: .allContents,
            size: 5
        )
        let grouped = makeSubCategory(
            name: "VS Code",
            locations: [selectedLocation, unselectedLocation]
        )
        let category = makeCategory(
            name: "IDE Caches",
            subcategories: [grouped]
        )
        let selectedSubcategory = grouped.updateLocations([selectedLocation])
        let context = makeSUT(totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.diskRepository.setComputeResponses([2, 0], for: selectedLocation.path)
        context.viewModel.categories = [category]

        context.viewModel.askRemoveSubcategories(
            from: category,
            subcategories: [selectedSubcategory]
        )
        _ = context.viewModel.startCleanup()

        let didFinishCleanup = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.categories[0].size == 5
        }

        #expect(didFinishCleanup)
        #expect(context.viewModel.categories[0].categories[0].locations == [
            selectedLocation.updateSize(0),
            unselectedLocation,
        ])
        #expect(context.diskRepository.cleanedPaths == [
            context.diskRepository.key(path: selectedLocation.path)
        ])
    }

    @Test func startCleanup_whenLocationsFail_listsExactPathsInAlert() async {
        struct ExpectedError: Error {}

        let first = StorageLocationEntity(
            path: "Library/Caches/Tool/A",
            rule: .allContents,
            size: 2
        )
        let second = StorageLocationEntity(
            path: "Library/Caches/Tool/B",
            rule: .allContents,
            size: 5
        )
        let grouped = makeSubCategory(name: "Tool", locations: [first, second])
        let category = makeCategory(
            name: "Development Tool Caches",
            subcategories: [grouped]
        )
        let context = makeSUT(totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.diskRepository.setComputeResponses([2, 2], for: first.path)
        context.diskRepository.setComputeResponses([5, 5], for: second.path)
        context.diskRepository.setCleanError(ExpectedError(), for: first.path)
        context.diskRepository.setCleanError(ExpectedError(), for: second.path)
        context.viewModel.categories = [category]

        context.viewModel.askRemoveDirectory(entity: category)
        _ = context.viewModel.startCleanup()

        let didShowFailure = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.isAlertErrorRequest
        }

        #expect(didShowFailure)
        #expect(
            context.viewModel.alertErrorMessage ==
            """
            The following cache paths could not be deleted:

            - Library/Caches/Tool/A
            - Library/Caches/Tool/B
            """
        )
        #expect(context.viewModel.isRetryFailedCleanupAvailable)
    }

    @Test func retryFailedCleanup_cleansOnlyPreviouslyFailedLocations() async {
        struct ExpectedError: Error {}

        let failedLocation = StorageLocationEntity(
            path: "Library/Caches/Tool/Failed",
            rule: .allContents,
            size: 2
        )
        let cleanedLocation = StorageLocationEntity(
            path: "Library/Caches/Tool/Cleaned",
            rule: .allContents,
            size: 5
        )
        let grouped = makeSubCategory(
            name: "Tool",
            locations: [failedLocation, cleanedLocation]
        )
        let category = makeCategory(
            name: "Development Tool Caches",
            subcategories: [grouped]
        )
        let context = makeSUT(totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.diskRepository.setComputeResponses([2, 2], for: failedLocation.path)
        context.diskRepository.setComputeResponses([5, 0], for: cleanedLocation.path)
        context.diskRepository.setCleanError(ExpectedError(), for: failedLocation.path)
        context.viewModel.categories = [category]

        context.viewModel.askRemoveDirectory(entity: category)
        _ = context.viewModel.startCleanup()

        let didFail = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.isRetryFailedCleanupAvailable
        }

        context.diskRepository.removeCleanError(for: failedLocation.path)
        context.diskRepository.setComputeResponses([2, 0], for: failedLocation.path)
        context.viewModel.retryFailedCleanup()

        let didRetry = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.categories[0].size == 0 &&
            context.cleanupProgressStore.isFinished
        }

        #expect(didFail)
        #expect(didRetry)
        #expect(context.viewModel.isRetryFailedCleanupAvailable == false)
        #expect(context.diskRepository.cleanedPaths == [
            context.diskRepository.key(path: failedLocation.path),
            context.diskRepository.key(path: cleanedLocation.path),
            context.diskRepository.key(path: failedLocation.path),
        ])
    }

    @Test func startCleanup_withoutSelection_cleansAllNonEmptyCategories() async {
        let firstCategory = makeCategory(
            name: "First",
            subcategories: [makeSubCategory(name: "Cache/A", size: 1.0)]
        )
        let secondCategory = makeCategory(
            name: "Second",
            subcategories: [makeSubCategory(name: "Cache/B", size: 2.0)]
        )
        let context = makeSUT(totalDiskCapacity: 300, availableDiskCapacity: 100)

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.diskRepository.setComputeResponses([1.0, 0], for: "Cache/A")
        context.diskRepository.setComputeResponses([2.0, 0], for: "Cache/B")
        context.viewModel.categories = [firstCategory, secondCategory]

        context.viewModel.askRemoveAllCaches()
        let cleanupName = context.viewModel.startCleanup()

        let didFinishCleanup = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.categories.allSatisfy { abs($0.size - 0) < 0.0001 } &&
            context.viewModel.categoryRowStates[firstCategory.id] == .ready &&
            context.viewModel.categoryRowStates[secondCategory.id] == .ready &&
            context.cleanupProgressStore.isFinished
        }

        #expect(cleanupName == "All Caches")
        #expect(didFinishCleanup)
        #expect(context.viewModel.storageCategorySelected == nil)
        #expect(context.diskRepository.cleanedPaths == [
            context.diskRepository.key(path: "Cache/A"),
            context.diskRepository.key(path: "Cache/B")
        ])
    }

    @Test func startCleanup_withoutSelection_whenWorkspaceIncluded_cleansAllCategoriesThenWorkspace() async {
        let category = makeCategory(
            name: "Caches",
            subcategories: [makeSubCategory(name: "Cache/A", size: 1.0)]
        )
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")
        let context = makeSUT(totalDiskCapacity: 300, availableDiskCapacity: 100)

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.scannerRepository.cleanupDirectories = ["node_modules"]
        context.diskRepository.setComputeResponses([1.0, 0], for: "Cache/A")
        context.diskRepository.setComputeResponses([25, 25, 0], for: "node_modules")
        context.viewModel.categories = [category]
        context.viewModel.selectWorkspace(url: workspaceURL)

        let didLoadWorkspace = await waitUntil(timeout: 2) {
            context.viewModel.workspaceRowState == .ready &&
            abs((context.viewModel.selectedWorkspaceCategory?.size ?? 0) - 25) < 0.0001
        }

        context.viewModel.askRemoveAllCaches()
        let cleanupName = context.viewModel.startCleanup(
            includeWorkspaceInAllCaches: true
        )

        let didFinishCleanup = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.workspaceRowState == .ready &&
            abs(context.viewModel.categories[0].size - 0) < 0.0001 &&
            abs((context.viewModel.selectedWorkspaceCategory?.size ?? -1) - 0) < 0.0001 &&
            context.cleanupProgressStore.isFinished
        }

        #expect(didLoadWorkspace)
        #expect(cleanupName == "All Caches + Workspace")
        #expect(didFinishCleanup)
        #expect(context.cleanupProgressStore.totalSize == 26)
        #expect(context.diskRepository.cleanedPaths == [
            context.diskRepository.key(path: "Cache/A"),
            context.diskRepository.key(path: "node_modules")
        ])
    }

    @Test func startMonitoring_refreshesAffectedCategoryAndStopsMonitoring() async {
        let category = makeCategory(
            name: "Caches",
            subcategories: [makeSubCategory(name: "Library/Caches/A")]
        )
        let context = makeSUT()

        context.homeAccessRepository.resolvedURL = testHomeURL
        context.diskRepository.setComputeResponses([3.0], for: "Library/Caches/A")
        context.viewModel.categories = [category]

        context.viewModel.startMonitoring()
        context.monitoringRepository.folderDidChange?("Library/Caches/A/file")

        let didRefresh = await waitUntil {
            abs(context.viewModel.categories[0].size - 3.0) < 0.0001
        }

        context.viewModel.stopMonitoring()

        #expect(context.monitoringRepository.startedURL == testHomeURL)
        #expect(didRefresh)
        #expect(context.viewModel.categoryRowStates[category.id] == nil)
        #expect(context.monitoringRepository.stopCallCount == 1)
    }

    @Test func selectCategoryForDetails_whenCategoriesReload_syncsSelectionByName() {
        let initialCategory = makeCategory(
            name: "Flutter/pub-cache",
            subcategories: [makeSubCategory(name: ".pub-cache", size: 1.0)]
        )
        let updatedCategory = makeCategory(
            name: "Flutter/pub-cache",
            subcategories: [makeSubCategory(name: ".pub-cache", size: 4.0)]
        )
        let context = makeSUT()

        context.viewModel.categories = [initialCategory]
        context.viewModel.selectCategoryForDetails(initialCategory)
        context.viewModel.categories = [updatedCategory]

        #expect(context.viewModel.selectedCategoryForDetails?.name == updatedCategory.name)
        #expect(context.viewModel.selectedCategoryForDetails?.id == updatedCategory.id)
        #expect(abs((context.viewModel.selectedCategoryForDetails?.size ?? 0) - 4.0) < 0.0001)
    }

    @Test func selectWorkspace_updatesSelectedWorkspaceDisplayState() {
        let context = makeSUT()
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")

        context.viewModel.selectWorkspace(url: workspaceURL)

        #expect(context.viewModel.selectedWorkspaceName == "MyApp")
        #expect(context.viewModel.selectedWorkspacePath == "/Users/test/Projects/MyApp")
        #expect(context.workspaceAccessRepository.savedURL == workspaceURL)
    }

    @Test func selectWorkspace_loadsWorkspaceCleanupCategoryAndDetails() async throws {
        let context = makeSUT()
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")

        context.scannerRepository.cleanupDirectories = ["node_modules"]
        context.diskRepository.setComputeResponses([25], for: "node_modules")

        context.viewModel.selectWorkspace(url: workspaceURL)

        let didLoadWorkspace = await waitUntil(timeout: 2) {
            context.viewModel.workspaceRowState == .ready &&
            context.viewModel.selectedWorkspaceCategory?.categories.map(\.path) == ["node_modules"]
        }

        context.viewModel.selectWorkspaceForDetails()

        #expect(didLoadWorkspace)
        #expect(context.viewModel.selectedWorkspaceCategory?.name == "Workspace: MyApp")
        #expect(abs((context.viewModel.selectedWorkspaceCategory?.size ?? 0) - 25) < 0.0001)
        #expect(context.viewModel.selectedWorkspaceCategoryForDetails?.categories.map(\.path) == ["node_modules"])
    }

    @Test func selectWorkspace_keepsWorkspaceRowLoadingWhileScannerRuns() async {
        let context = makeSUT()
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")

        context.scannerRepository.cleanupDirectoryDelayNanoseconds = 100_000_000
        context.scannerRepository.cleanupDirectories = ["node_modules"]
        context.diskRepository.setComputeResponses([25], for: "node_modules")

        context.viewModel.selectWorkspace(url: workspaceURL)

        #expect(context.viewModel.workspaceRowState == .loading)

        try? await Task.sleep(nanoseconds: 20_000_000)

        #expect(context.viewModel.workspaceRowState == .loading)

        let didLoadWorkspace = await waitUntil(timeout: 2) {
            context.viewModel.workspaceRowState == .ready &&
            context.viewModel.selectedWorkspaceCategory?.categories.map(\.path) == ["node_modules"]
        }

        #expect(didLoadWorkspace)
    }

    @Test func resolveWorkspaceAccess_whenAvailableRestoresSelectedWorkspace() async {
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")
        let context = makeSUT(
            resolvedWorkspaceURL: workspaceURL,
            workspaceCleanupDirectories: ["node_modules"],
            workspaceDirectorySizes: ["node_modules": 25]
        )

        let didLoadWorkspace = await waitUntil(timeout: 2) {
            context.viewModel.workspaceRowState == .ready &&
            context.viewModel.selectedWorkspaceCategory?.categories.map(\.path) == ["node_modules"]
        }

        #expect(didLoadWorkspace)
        #expect(context.viewModel.selectedWorkspaceName == "MyApp")
        #expect(context.viewModel.selectedWorkspacePath == "/Users/test/Projects/MyApp")
        #expect(context.workspaceAccessRepository.saveCallCount == 0)
    }

    @Test func settingsStore_whenWorkspaceChanges_updatesSelectedWorkspace() async {
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")
        let context = makeSUT(
            workspaceCleanupDirectories: ["node_modules"],
            workspaceDirectorySizes: ["node_modules": 25]
        )

        context.settingsStore.selectedWorkspaceURL = workspaceURL

        let didLoadWorkspace = await waitUntil(timeout: 2) {
            context.viewModel.workspaceRowState == .ready &&
            context.viewModel.selectedWorkspaceName == "MyApp" &&
            context.viewModel.selectedWorkspacePath == "/Users/test/Projects/MyApp" &&
            context.viewModel.selectedWorkspaceCategory?.categories.map(\.path) == ["node_modules"]
        }

        #expect(didLoadWorkspace)
        #expect(context.workspaceAccessRepository.saveCallCount == 0)
    }

    @Test func startupPrompt_whenInitialOverviewFinishesAndStartupIsDisabled_showsPrompt() async {
        let context = makeSUT(
            resolvedURL: testHomeURL,
            launchAtStartupStatus: .disabled
        )

        let didShowPrompt = await waitUntil(timeout: 2) {
            context.viewModel.isLaunchAtStartupPromptVisible
        }

        #expect(didShowPrompt)
    }

    @Test func dismissLaunchAtStartupPrompt_hidesPromptAndPersistsDismissal() async {
        let context = makeSUT(
            resolvedURL: testHomeURL,
            launchAtStartupStatus: .disabled
        )

        let didShowPrompt = await waitUntil(timeout: 2) {
            context.viewModel.isLaunchAtStartupPromptVisible
        }

        context.viewModel.dismissLaunchAtStartupPrompt()

        #expect(didShowPrompt)
        #expect(context.viewModel.isLaunchAtStartupPromptVisible == false)
        #expect(context.launchAtStartupPromptRepository.promptDismissed)
        #expect(context.launchAtStartupPromptRepository.setPromptDismissedCallCount == 1)
    }

    @Test func enableLaunchAtStartup_whenApprovalIsRequired_hidesPromptAndShowsAlert() async {
        let context = makeSUT(
            resolvedURL: testHomeURL,
            launchAtStartupStatus: .disabled
        )
        context.launchAtStartupRepository.nextResolvedStatusAfterUpdate = .requiresApproval

        let didShowPrompt = await waitUntil(timeout: 2) {
            context.viewModel.isLaunchAtStartupPromptVisible
        }

        context.viewModel.enableLaunchAtStartup()

        #expect(didShowPrompt)
        #expect(context.launchAtStartupRepository.updateCallCount == 1)
        #expect(context.launchAtStartupRepository.updatedIsEnabled == true)
        #expect(context.viewModel.isLaunchAtStartupPromptVisible == false)
        #expect(context.launchAtStartupPromptRepository.promptDismissed)
        #expect(context.viewModel.isAlertErrorRequest)
        #expect(
            context.viewModel.alertErrorMessage ==
            "Approval is required in System Settings > Login Items."
        )
    }

    @Test func startCleanup_forWorkspace_updatesWorkspaceCategoryAndResetsState() async {
        let context = makeSUT(totalDiskCapacity: 500, availableDiskCapacity: 200)
        let workspaceURL = URL(filePath: "/Users/test/Projects/MyApp")

        context.scannerRepository.cleanupDirectories = ["node_modules"]
        context.diskRepository.setComputeResponses([25, 25, 0], for: "node_modules")

        context.viewModel.selectWorkspace(url: workspaceURL)

        let didLoadWorkspace = await waitUntil(timeout: 2) {
            context.viewModel.workspaceRowState == .ready &&
            abs((context.viewModel.selectedWorkspaceCategory?.size ?? 0) - 25) < 0.0001
        }

        context.viewModel.askRemoveWorkspaceCaches()
        let cleanupName = context.viewModel.startCleanup()

        let didFinishCleanup = await waitUntil(timeout: 2) {
            context.viewModel.isCleaning == false &&
            context.viewModel.workspaceRowState == .ready &&
            abs((context.viewModel.selectedWorkspaceCategory?.size ?? -1) - 0) < 0.0001 &&
            context.cleanupProgressStore.isFinished
        }

        #expect(didLoadWorkspace)
        #expect(cleanupName == "Workspace: MyApp")
        #expect(didFinishCleanup)
        #expect(context.viewModel.storageCategorySelected == nil)
        #expect(context.cleanupProgressStore.categoryName == "Workspace: MyApp")
        #expect(context.diskRepository.cleanedPaths == [
            context.diskRepository.key(path: "node_modules")
        ])
    }
}

@MainActor
private func makeSUT(
    shouldSaveHomeURL: Bool = true,
    resolvedURL: URL? = nil,
    resolvedWorkspaceURL: URL? = nil,
    workspaceCleanupDirectories: [String] = [],
    workspaceDirectorySizes: [String: CGFloat] = [:],
    launchAtStartupStatus: LaunchAtStartupStatusEntity = .enabled,
    totalDiskCapacity: CGFloat = 0,
    availableDiskCapacity: CGFloat = 0
) -> (
    viewModel: CleanerHomeViewModel,
    diskRepository: DiskRepositoryMock,
    scannerRepository: DiskScannerRepositoryMock,
    settingsStore: SettingsStore,
    workspaceAccessRepository: WorkspaceAccessRepositoryMock,
    launchAtStartupRepository: LaunchAtStartupRepositoryMock,
    launchAtStartupPromptRepository: LaunchAtStartupPromptRepositoryMock,
    homeAccessRepository: HomeAccessRepositoryMock,
    monitoringRepository: DiskMonitoringRepositoryMock,
    cleanupProgressStore: CleanupProgressStore
) {
    let diskRepository = DiskRepositoryMock()
    diskRepository.totalDiskCapacity = totalDiskCapacity
    diskRepository.availableDiskCapacity = availableDiskCapacity

    let scannerRepository = DiskScannerRepositoryMock()
    scannerRepository.cleanupDirectories = workspaceCleanupDirectories

    for (path, size) in workspaceDirectorySizes {
        diskRepository.setComputeResponses([size], for: path)
    }

    let workspaceAccessRepository = WorkspaceAccessRepositoryMock()
    workspaceAccessRepository.resolvedURL = resolvedWorkspaceURL

    let launchAtStartupRepository = LaunchAtStartupRepositoryMock()
    launchAtStartupRepository.resolvedStatus = launchAtStartupStatus

    let launchAtStartupPromptRepository = LaunchAtStartupPromptRepositoryMock()

    let homeAccessRepository = HomeAccessRepositoryMock()
    homeAccessRepository.shouldSaveHomeURL = shouldSaveHomeURL
    homeAccessRepository.resolvedURL = resolvedURL

    let monitoringRepository = DiskMonitoringRepositoryMock()
    let cleanupProgressStore = CleanupProgressStore()

    let saveHomeAccessUseCase = SaveHomeAccessUseCase(homeAccessRepository: homeAccessRepository)
    let resolveHomeAccessUseCase = ResolveHomeAccessUseCase(homeAccessRepository: homeAccessRepository)
    let buildStorageCategoriesUseCase = BuildStorageCategoriesUseCase()
    let observeDiskChangesUseCase = ObserveDiskChangesUseCase(
        diskMonitoringRepository: monitoringRepository
    )
    let cleanStorageCategoryUseCase = CleanStorageCategoryUseCase(diskRepository: diskRepository)
    let cleanAllStorageCategoriesUseCase = CleanAllStorageCategoriesUseCase(
        cleanStorageCategoryUseCase: cleanStorageCategoryUseCase
    )
    let refreshStorageCategoryUseCase = RefreshStorageCategoryUseCase(diskRepository: diskRepository)
    let loadStorageOverviewUseCase = LoadStorageOverviewUseCase(
        diskRepository: diskRepository,
        buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: refreshStorageCategoryUseCase
    )
    let loadWorkspaceCleanupCategoryUseCase = LoadWorkspaceCleanupCategoryUseCase(
        diskRepository: diskRepository,
        diskScannerRepository: scannerRepository
    )
    let saveWorkspaceAccessUseCase = SaveWorkspaceAccessUseCase(
        workspaceAccessRepository: workspaceAccessRepository
    )
    let resolveWorkspaceAccessUseCase = ResolveWorkspaceAccessUseCase(
        workspaceAccessRepository: workspaceAccessRepository
    )
    let resolveLaunchAtStartupStatusUseCase = ResolveLaunchAtStartupStatusUseCase(
        launchAtStartupRepository: launchAtStartupRepository
    )
    let updateLaunchAtStartupStatusUseCase = UpdateLaunchAtStartupStatusUseCase(
        launchAtStartupRepository: launchAtStartupRepository
    )
    let resolveLaunchAtStartupPromptDismissalUseCase = ResolveLaunchAtStartupPromptDismissalUseCase(
        launchAtStartupPromptRepository: launchAtStartupPromptRepository
    )
    let dismissLaunchAtStartupPromptUseCase = DismissLaunchAtStartupPromptUseCase(
        launchAtStartupPromptRepository: launchAtStartupPromptRepository
    )
    let readDiskSpaceUseCase = ReadDiskSpaceUseCase(diskRepository: diskRepository)
    let settingsStore = SettingsStore()

    let viewModel = CleanerHomeViewModel(
        saveHomeAccessUseCase: saveHomeAccessUseCase,
        resolveHomeAccessUseCase: resolveHomeAccessUseCase,
        buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
        observeDiskChangesUseCase: observeDiskChangesUseCase,
        cleanStorageCategoryUseCase: cleanStorageCategoryUseCase,
        cleanAllStorageCategoriesUseCase: cleanAllStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: refreshStorageCategoryUseCase,
        loadStorageOverviewUseCase: loadStorageOverviewUseCase,
        loadWorkspaceCleanupCategoryUseCase: loadWorkspaceCleanupCategoryUseCase,
        settingsStore: settingsStore,
        saveWorkspaceAccessUseCase: saveWorkspaceAccessUseCase,
        resolveWorkspaceAccessUseCase: resolveWorkspaceAccessUseCase,
        resolveLaunchAtStartupStatusUseCase: resolveLaunchAtStartupStatusUseCase,
        updateLaunchAtStartupStatusUseCase: updateLaunchAtStartupStatusUseCase,
        resolveLaunchAtStartupPromptDismissalUseCase: resolveLaunchAtStartupPromptDismissalUseCase,
        dismissLaunchAtStartupPromptUseCase: dismissLaunchAtStartupPromptUseCase,
        readDiskSpaceUseCase: readDiskSpaceUseCase,
        cleanupProgressStore: cleanupProgressStore
    )

    return (
        viewModel: viewModel,
        diskRepository: diskRepository,
        scannerRepository: scannerRepository,
        settingsStore: settingsStore,
        workspaceAccessRepository: workspaceAccessRepository,
        launchAtStartupRepository: launchAtStartupRepository,
        launchAtStartupPromptRepository: launchAtStartupPromptRepository,
        homeAccessRepository: homeAccessRepository,
        monitoringRepository: monitoringRepository,
        cleanupProgressStore: cleanupProgressStore
    )
}
