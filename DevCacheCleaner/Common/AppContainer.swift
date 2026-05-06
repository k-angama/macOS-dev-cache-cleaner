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
    private let supportTipsManager = SupportTipsManager()

    private lazy var diskManager = DiskManagerImpl()
    private lazy var diskScannerManager = DiskScannerManager()
    private lazy var diskMonitorManager = DiskMonitorManagerImpl()

    private lazy var directoryAccessManager = DirectoryAccessManager(params: parameters)
    private lazy var launchAtStartupManager = LaunchAtStartupManager()

    // MARK: - Stores

    private lazy var cleanupProgressStore = CleanupProgressStore()
    private lazy var settingsStore = SettingsStore()

    // MARK: - Presentation DI

    lazy var cleanerHomeDI = CleanerHomeDI(
        diskManager: diskManager,
        diskScannerManager: diskScannerManager,
        diskMonitorManager: diskMonitorManager,
        directoryAccessManager: directoryAccessManager,
        launchAtStartupManager: launchAtStartupManager,
        parameters: parameters,
        settingsStore: settingsStore,
        cleanupProgressStore: cleanupProgressStore
    )

    lazy var settingsDI = SettingsDI(
        directoryAccessManager: directoryAccessManager,
        launchAtStartupManager: launchAtStartupManager,
        settingsStore: settingsStore
    )

    lazy var cleanupProgressDI = CleanupProgressDI(
        store: cleanupProgressStore
    )

    lazy var supportDI = SupportDI(
        supportTipsManager: supportTipsManager
    )
}
