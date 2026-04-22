import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct CleanerHomeViewModelTests {

    @Test func requestUserDirectoryAccess_whenGranted_marksAccessAndLoadsOverview() async {
        let context = makeSUT(requestedURL: testHomeURL, totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.viewModel.requestUserDirectoryAccess()

        let didLoadOverview = await waitUntil {
            context.viewModel.isAccessUserDirectory &&
            context.viewModel.categoryRowStates.count == context.viewModel.categories.count &&
            context.viewModel.categoryRowStates.values.allSatisfy { $0 == .ready }
        }

        #expect(didLoadOverview)
        #expect(context.homeAccessRepository.requestCallCount == 1)
        #expect(context.viewModel.isAccessUserDirectory)
        #expect(context.viewModel.totalSize == 500)
        #expect(context.viewModel.freeSize == 200)
        #expect(context.viewModel.isAlertErrorRequest == false)
    }

    @Test func requestUserDirectoryAccess_whenDenied_showsErrorAlert() {
        let context = makeSUT()

        context.viewModel.requestUserDirectoryAccess()

        #expect(context.homeAccessRepository.requestCallCount == 1)
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
        context.diskRepository.setCleanFileDeletionSteps([1.0, 1.5], for: ".pub-cache")
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
        context.diskRepository.setCleanFileDeletionSteps([1.0], for: "Cache/A")
        context.diskRepository.setCleanFileDeletionSteps([2.0], for: "Cache/B")
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

    @Test func clearSelectedCategoryForDetails_clearsDetailsSelection() {
        let category = makeCategory(
            name: "Flutter/pub-cache",
            subcategories: [makeSubCategory(name: ".pub-cache", size: 1.0)]
        )
        let context = makeSUT()

        context.viewModel.categories = [category]
        context.viewModel.selectCategoryForDetails(category)
        context.viewModel.clearSelectedCategoryForDetails()

        #expect(context.viewModel.selectedCategoryForDetails == nil)
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
        #expect(context.workspaceAccessRepository.resolveCallCount == 1)
        #expect(context.workspaceAccessRepository.saveCallCount == 0)
    }
}

@MainActor
private func makeSUT(
    requestedURL: URL? = nil,
    resolvedURL: URL? = nil,
    resolvedWorkspaceURL: URL? = nil,
    workspaceCleanupDirectories: [String] = [],
    workspaceDirectorySizes: [String: CGFloat] = [:],
    totalDiskCapacity: CGFloat = 0,
    availableDiskCapacity: CGFloat = 0
) -> (
    viewModel: CleanerHomeViewModel,
    diskRepository: DiskRepositoryMock,
    scannerRepository: DiskScannerRepositoryMock,
    workspaceAccessRepository: WorkspaceAccessRepositoryMock,
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

    let homeAccessRepository = HomeAccessRepositoryMock()
    homeAccessRepository.requestedURL = requestedURL
    homeAccessRepository.resolvedURL = resolvedURL

    let monitoringRepository = DiskMonitoringRepositoryMock()
    let cleanupProgressStore = CleanupProgressStore()

    let requestHomeAccessUseCase = RequestHomeAccessUseCase(homeAccessRepository: homeAccessRepository)
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
    let readDiskSpaceUseCase = ReadDiskSpaceUseCase(diskRepository: diskRepository)

    let viewModel = CleanerHomeViewModel(
        requestHomeAccessUseCase: requestHomeAccessUseCase,
        resolveHomeAccessUseCase: resolveHomeAccessUseCase,
        buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
        observeDiskChangesUseCase: observeDiskChangesUseCase,
        cleanStorageCategoryUseCase: cleanStorageCategoryUseCase,
        cleanAllStorageCategoriesUseCase: cleanAllStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: refreshStorageCategoryUseCase,
        loadStorageOverviewUseCase: loadStorageOverviewUseCase,
        loadWorkspaceCleanupCategoryUseCase: loadWorkspaceCleanupCategoryUseCase,
        saveWorkspaceAccessUseCase: saveWorkspaceAccessUseCase,
        resolveWorkspaceAccessUseCase: resolveWorkspaceAccessUseCase,
        readDiskSpaceUseCase: readDiskSpaceUseCase,
        cleanupProgressStore: cleanupProgressStore
    )

    return (
        viewModel: viewModel,
        diskRepository: diskRepository,
        scannerRepository: scannerRepository,
        workspaceAccessRepository: workspaceAccessRepository,
        homeAccessRepository: homeAccessRepository,
        monitoringRepository: monitoringRepository,
        cleanupProgressStore: cleanupProgressStore
    )
}
