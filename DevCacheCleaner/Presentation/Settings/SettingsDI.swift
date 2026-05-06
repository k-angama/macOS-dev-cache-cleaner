//
//  SettingsDI.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation

class SettingsDI: PresentationDI {
    private let directoryAccessManager: DirectoryAccessManaging
    private let launchAtStartupManager: LaunchAtStartupManaging
    private let settingsStore: SettingsStore
    
    init(
        directoryAccessManager: DirectoryAccessManaging,
        launchAtStartupManager: LaunchAtStartupManaging,
        settingsStore: SettingsStore
    ) {
        self.directoryAccessManager = directoryAccessManager
        self.launchAtStartupManager = launchAtStartupManager
        self.settingsStore = settingsStore
    }
    
    func start(data: Void) -> SettingsView {
        SettingsView(viewModel: viewModel)
    }
    
    private lazy var viewModel: SettingsViewModel = {
        let workspaceAccessRepository = WorkspaceAccessRepositoryImpl(
            manager: directoryAccessManager
        )
        let launchAtStartupRepository = LaunchAtStartupRepositoryImpl(
            manager: launchAtStartupManager
        )
        
        let saveWorkspaceAccessUseCase = SaveWorkspaceAccessUseCase(
            workspaceAccessRepository: workspaceAccessRepository
        )
        let resolveLaunchAtStartupStatusUseCase = ResolveLaunchAtStartupStatusUseCase(
            launchAtStartupRepository: launchAtStartupRepository
        )
        let updateLaunchAtStartupStatusUseCase = UpdateLaunchAtStartupStatusUseCase(
            launchAtStartupRepository: launchAtStartupRepository
        )
        return SettingsViewModel(
            saveWorkspaceAccessUseCase: saveWorkspaceAccessUseCase,
            resolveLaunchAtStartupStatusUseCase: resolveLaunchAtStartupStatusUseCase,
            updateLaunchAtStartupStatusUseCase: updateLaunchAtStartupStatusUseCase,
            settingsStore: settingsStore
        )
    }()
    
}
