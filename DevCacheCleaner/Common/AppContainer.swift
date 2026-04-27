//
//  AppContainer.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 08/03/2026.
//

import Foundation

class AppContainer {

    init() {
        Task {
            await supportTipsManager.startObservingTransactions()
        }
    }

    // MARK: - Infrastructure

    private lazy var parameters: Parameters = ParametersImpl()
    private let supportTipsManager = SupportTipsManager()

    private lazy var diskRepository: DiskRepository = DiskRepositoryImpl(
        manager: DiskManagerImpl()
    )

    private lazy var diskScannerRepository: DiskScannerRepository = DiskScannerRepositoryImpl(
        manager: DiskScannerManager()
    )

    private lazy var diskMonitoringRepository: DiskMonitoringRepository = DiskMonitoringRepositoryImpl(
        manager: DiskMonitorManagerImpl()
    )

    private lazy var directoryAccessManager = DirectoryAccessManager(params: parameters)
    private lazy var launchAtStartupManager = LaunchAtStartupManager()

    private lazy var homeAccessRepository: HomeAccessRepository = HomeAccessRepositoryImpl(
        manager: directoryAccessManager
    )

    private lazy var workspaceAccessRepository: WorkspaceAccessRepository = WorkspaceAccessRepositoryImpl(
        manager: directoryAccessManager
    )

    private lazy var launchAtStartupRepository: LaunchAtStartupRepository = LaunchAtStartupRepositoryImpl(
        manager: launchAtStartupManager
    )

    private lazy var launchAtStartupPromptRepository: LaunchAtStartupPromptRepository = LaunchAtStartupPromptRepositoryImpl(
        parameters: parameters
    )

    private lazy var supportTipsRepository: SupportTipsRepository = SupportTipsRepositoryImpl(
        manager: supportTipsManager
    )

    // MARK: - Stores

    private lazy var cleanupProgressStore = CleanupProgressStore()
    private lazy var settingsStore = SettingsStore()

    // MARK: - Use Cases

    private lazy var buildStorageCategoriesUseCase = BuildStorageCategoriesUseCase()

    private lazy var refreshStorageCategoryUseCase = RefreshStorageCategoryUseCase(
        diskRepository: diskRepository
    )

    private lazy var loadStorageOverviewUseCase = LoadStorageOverviewUseCase(
        diskRepository: diskRepository,
        buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: refreshStorageCategoryUseCase
    )

    private lazy var loadWorkspaceCleanupCategoryUseCase = LoadWorkspaceCleanupCategoryUseCase(
        diskRepository: diskRepository,
        diskScannerRepository: diskScannerRepository
    )

    private lazy var readDiskSpaceUseCase = ReadDiskSpaceUseCase(
        diskRepository: diskRepository
    )

    private lazy var cleanStorageCategoryUseCase = CleanStorageCategoryUseCase(
        diskRepository: diskRepository
    )

    private lazy var cleanAllStorageCategoriesUseCase = CleanAllStorageCategoriesUseCase(
        cleanStorageCategoryUseCase: cleanStorageCategoryUseCase
    )

    private lazy var observeDiskChangesUseCase = ObserveDiskChangesUseCase(
        diskMonitoringRepository: diskMonitoringRepository
    )

    private lazy var saveHomeAccessUseCase = SaveHomeAccessUseCase(
        homeAccessRepository: homeAccessRepository
    )

    private lazy var resolveHomeAccessUseCase = ResolveHomeAccessUseCase(
        homeAccessRepository: homeAccessRepository
    )

    private lazy var saveWorkspaceAccessUseCase = SaveWorkspaceAccessUseCase(
        workspaceAccessRepository: workspaceAccessRepository
    )

    private lazy var resolveWorkspaceAccessUseCase = ResolveWorkspaceAccessUseCase(
        workspaceAccessRepository: workspaceAccessRepository
    )

    private lazy var resolveLaunchAtStartupStatusUseCase = ResolveLaunchAtStartupStatusUseCase(
        launchAtStartupRepository: launchAtStartupRepository
    )

    private lazy var updateLaunchAtStartupStatusUseCase = UpdateLaunchAtStartupStatusUseCase(
        launchAtStartupRepository: launchAtStartupRepository
    )

    private lazy var resolveLaunchAtStartupPromptDismissalUseCase = ResolveLaunchAtStartupPromptDismissalUseCase(
        launchAtStartupPromptRepository: launchAtStartupPromptRepository
    )

    private lazy var dismissLaunchAtStartupPromptUseCase = DismissLaunchAtStartupPromptUseCase(
        launchAtStartupPromptRepository: launchAtStartupPromptRepository
    )

    private lazy var loadSupportTipProductsUseCase = LoadSupportTipProductsUseCase(
        supportTipsRepository: supportTipsRepository
    )

    private lazy var purchaseSupportTipUseCase = PurchaseSupportTipUseCase(
        supportTipsRepository: supportTipsRepository
    )

    // MARK: - ViewModels

    lazy var cleanupProgressViewModel = CleanupProgressViewModel(
        store: cleanupProgressStore
    )

    lazy var cleanerHomeViewModel = CleanerHomeViewModel(
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
    
    lazy var settingsViewModel: SettingsViewModel = {
        SettingsViewModel(
            saveWorkspaceAccessUseCase: saveWorkspaceAccessUseCase,
            resolveLaunchAtStartupStatusUseCase: resolveLaunchAtStartupStatusUseCase,
            updateLaunchAtStartupStatusUseCase: updateLaunchAtStartupStatusUseCase,
            settingsStore: settingsStore
        )
    }()
    
    lazy var supportViewModel: SupportViewModel = {
        SupportViewModel(
            loadSupportTipProductsUseCase: loadSupportTipProductsUseCase,
            purchaseSupportTipUseCase: purchaseSupportTipUseCase
        )
    }()
}
