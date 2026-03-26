//
//  AppContainer.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 08/03/2026.
//

import Foundation
import SwiftUI

class AppContainer {
    
    private lazy var parameters: Parameters = ParametersImpl()
    private lazy var cleanupProgressStore = CleanupProgressStore()
    private lazy var diskRepository: DiskRepository = {
        DiskRepositoryImpl(manager: DiskManagerImpl())
    }()
    private lazy var cleanStorageCategoryUseCase = CleanStorageCategoryUseCase(
        diskRepository: diskRepository
    )
    private lazy var cleanAllStorageCategoriesUseCase = CleanAllStorageCategoriesUseCase(
        cleanStorageCategoryUseCase: cleanStorageCategoryUseCase
    )
    private lazy var refreshStorageCategoryUseCase = RefreshStorageCategoryUseCase(
        diskRepository: diskRepository
    )
    private lazy var readDiskSpaceUseCase = ReadDiskSpaceUseCase(
        diskRepository: diskRepository
    )
    private lazy var buildStorageCategoriesUseCase = BuildStorageCategoriesUseCase()
    private lazy var loadStorageOverviewUseCase = LoadStorageOverviewUseCase(
        diskRepository: diskRepository,
        buildStorageCategoriesUseCase: buildStorageCategoriesUseCase,
        refreshStorageCategoryUseCase: refreshStorageCategoryUseCase
    )
    private lazy var homeAccessRepository: HomeAccessRepository = {
        HomeAccessRepositoryImpl(
            manager: HomeAccessManager(params: parameters)
        )
    }()
    private lazy var requestHomeAccessUseCase = RequestHomeAccessUseCase(
        homeAccessRepository: homeAccessRepository
    )
    private lazy var resolveHomeAccessUseCase = ResolveHomeAccessUseCase(
        homeAccessRepository: homeAccessRepository
    )
    
    private lazy var diskMonitorManager: DiskMonitoringRepository = {
        DiskMonitoringRepositoryImpl(manager: DiskMonitorManagerImpl())
    }()
    private lazy var observeDiskChangesUseCase = ObserveDiskChangesUseCase(
        diskMonitoringRepository: diskMonitorManager
    )
    
    lazy var cleanerHomeViewModel: CleanerHomeViewModel = {
        CleanerHomeViewModel(
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
    }()
    
    lazy var cleanupProgressViewModel: CleanupProgressViewModel = {
        CleanupProgressViewModel(store: cleanupProgressStore)
    }()
    
}
