//
//  CleanerHomeDI.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

final class CleanerHomeDI: PresentationDI {
    private let diskManager: DiskManager
    private let diskScannerManager: DiskScannerManager
    private let diskMonitorManager: DiskMonitorManager
    private let directoryAccessManager: DirectoryAccessManaging
    private let launchAtStartupManager: LaunchAtStartupManaging
    private let parameters: Parameters
    private let settingsStore: SettingsStore
    private let cleanupProgressStore: CleanupProgressStore

    init(
        diskManager: DiskManager,
        diskScannerManager: DiskScannerManager,
        diskMonitorManager: DiskMonitorManager,
        directoryAccessManager: DirectoryAccessManaging,
        launchAtStartupManager: LaunchAtStartupManaging,
        parameters: Parameters,
        settingsStore: SettingsStore,
        cleanupProgressStore: CleanupProgressStore
    ) {
        self.diskManager = diskManager
        self.diskScannerManager = diskScannerManager
        self.diskMonitorManager = diskMonitorManager
        self.directoryAccessManager = directoryAccessManager
        self.launchAtStartupManager = launchAtStartupManager
        self.parameters = parameters
        self.settingsStore = settingsStore
        self.cleanupProgressStore = cleanupProgressStore
    }

    func start(data: Void) -> CleanerHomeView {
        CleanerHomeView(viewModel: viewModel)
    }

    private lazy var viewModel: CleanerHomeViewModel = {
        let diskRepository = DiskRepositoryImpl(
            manager: diskManager
        )
        let diskScannerRepository = DiskScannerRepositoryImpl(
            manager: diskScannerManager
        )
        let diskMonitoringRepository = DiskMonitoringRepositoryImpl(
            manager: diskMonitorManager
        )
        let homeAccessRepository = HomeAccessRepositoryImpl(
            manager: directoryAccessManager
        )
        let workspaceAccessRepository = WorkspaceAccessRepositoryImpl(
            manager: directoryAccessManager
        )
        let launchAtStartupRepository = LaunchAtStartupRepositoryImpl(
            manager: launchAtStartupManager
        )
        let launchAtStartupPromptRepository = LaunchAtStartupPromptRepositoryImpl(
            parameters: parameters
        )

        let buildStorageCategoriesUseCase = BuildStorageCategoriesUseCase()
        let refreshStorageCategoryUseCase = RefreshStorageCategoryUseCase(
            diskRepository: diskRepository
        )
        let cleanStorageCategoryUseCase = CleanStorageCategoryUseCase(
            diskRepository: diskRepository
        )

        return CleanerHomeViewModel(
            saveHomeAccessUseCase: SaveHomeAccessUseCase(
                homeAccessRepository: homeAccessRepository
            ),
            resolveHomeAccessUseCase: ResolveHomeAccessUseCase(
                homeAccessRepository: homeAccessRepository
            ),
            buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
            observeDiskChangesUseCase: ObserveDiskChangesUseCase(
                diskMonitoringRepository: diskMonitoringRepository
            ),
            cleanStorageCategoryUseCase: cleanStorageCategoryUseCase,
            cleanAllStorageCategoriesUseCase: CleanAllStorageCategoriesUseCase(
                cleanStorageCategoryUseCase: cleanStorageCategoryUseCase
            ),
            refreshStorageCategoryUseCase: refreshStorageCategoryUseCase,
            loadStorageOverviewUseCase: LoadStorageOverviewUseCase(
                diskRepository: diskRepository,
                buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
                refreshStorageCategoryUseCase: refreshStorageCategoryUseCase
            ),
            loadWorkspaceCleanupCategoryUseCase: LoadWorkspaceCleanupCategoryUseCase(
                diskRepository: diskRepository,
                diskScannerRepository: diskScannerRepository
            ),
            settingsStore: settingsStore,
            saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase(
                workspaceAccessRepository: workspaceAccessRepository
            ),
            resolveWorkspaceAccessUseCase: ResolveWorkspaceAccessUseCase(
                workspaceAccessRepository: workspaceAccessRepository
            ),
            resolveLaunchAtStartupStatusUseCase: ResolveLaunchAtStartupStatusUseCase(
                launchAtStartupRepository: launchAtStartupRepository
            ),
            updateLaunchAtStartupStatusUseCase: UpdateLaunchAtStartupStatusUseCase(
                launchAtStartupRepository: launchAtStartupRepository
            ),
            resolveLaunchAtStartupPromptDismissalUseCase: ResolveLaunchAtStartupPromptDismissalUseCase(
                launchAtStartupPromptRepository: launchAtStartupPromptRepository
            ),
            dismissLaunchAtStartupPromptUseCase: DismissLaunchAtStartupPromptUseCase(
                launchAtStartupPromptRepository: launchAtStartupPromptRepository
            ),
            readDiskSpaceUseCase: ReadDiskSpaceUseCase(
                diskRepository: diskRepository
            ),
            cleanupProgressStore: cleanupProgressStore
        )
    }()
}

extension CleanerHomeDI {
    func startPreview(configure: (CleanerHomeViewModel) -> Void) -> CleanerHomeView {
        configure(viewModel)
        return start()
    }
}
