//
//  AppContainer.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 08/03/2026.
//

import Foundation

class AppContainer {

    // MARK: - Infrastructure

    private lazy var parameters: Parameters = ParametersImpl()

    private lazy var diskRepository: DiskRepository = DiskRepositoryImpl(
        manager: DiskManagerImpl()
    )

    private lazy var diskMonitoringRepository: DiskMonitoringRepository = DiskMonitoringRepositoryImpl(
        manager: DiskMonitorManagerImpl()
    )

    private lazy var homeAccessRepository: HomeAccessRepository = HomeAccessRepositoryImpl(
        manager: HomeAccessManager(params: parameters)
    )

    // MARK: - Stores

    private lazy var cleanupProgressStore = CleanupProgressStore()

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

    private lazy var requestHomeAccessUseCase = RequestHomeAccessUseCase(
        homeAccessRepository: homeAccessRepository
    )

    private lazy var resolveHomeAccessUseCase = ResolveHomeAccessUseCase(
        homeAccessRepository: homeAccessRepository
    )

    // MARK: - ViewModels

    lazy var cleanupProgressViewModel = CleanupProgressViewModel(
        store: cleanupProgressStore
    )

    lazy var cleanerHomeViewModel = CleanerHomeViewModel(
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
}
