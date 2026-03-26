import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct CleanerHomeViewModelTests {

    @Test func requestUserDirectoryAccess_whenGranted_marksAccessAndLoadsOverview() async {
        let context = makeSUT(requestedURL: testHomeURL, totalDiskCapacity: 500, availableDiskCapacity: 200)

        context.viewModel.requesUserDirectoryAccess()

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

        context.viewModel.requesUserDirectoryAccess()

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

        context.viewModel.askRemoveDirectory(entiy: category)
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
            context.diskRepository.key(path: ".pub-cache", match: "")
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
            context.diskRepository.key(path: "Cache/A", match: ""),
            context.diskRepository.key(path: "Cache/B", match: "")
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
            abs(context.viewModel.categories[0].size - 3.0) < 0.0001 &&
            context.viewModel.categoryRowStates[category.id] == .ready
        }

        context.viewModel.stopMonitoring()

        #expect(context.monitoringRepository.startedURL == testHomeURL)
        #expect(didRefresh)
        #expect(context.monitoringRepository.stopCallCount == 1)
    }
}

@MainActor
private func makeSUT(
    requestedURL: URL? = nil,
    resolvedURL: URL? = nil,
    totalDiskCapacity: CGFloat = 0,
    availableDiskCapacity: CGFloat = 0
) -> (
    viewModel: CleanerHomeViewModel,
    diskRepository: DiskRepositoryMock,
    homeAccessRepository: HomeAccessRepositoryMock,
    monitoringRepository: DiskMonitoringRepositoryMock,
    cleanupProgressStore: CleanupProgressStore
) {
    let diskRepository = DiskRepositoryMock()
    diskRepository.totalDiskCapacity = totalDiskCapacity
    diskRepository.availableDiskCapacity = availableDiskCapacity

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
        readDiskSpaceUseCase: readDiskSpaceUseCase,
        cleanupProgressStore: cleanupProgressStore
    )

    return (
        viewModel: viewModel,
        diskRepository: diskRepository,
        homeAccessRepository: homeAccessRepository,
        monitoringRepository: monitoringRepository,
        cleanupProgressStore: cleanupProgressStore
    )
}
