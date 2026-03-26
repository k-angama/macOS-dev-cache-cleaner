//
//  DiskMonitoringRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

/// Default repository implementation that forwards to a DiskMonitorManager.
struct DiskMonitoringRepositoryImpl: DiskMonitoringRepository {
    private var manager: DiskMonitorManager

    init(manager: DiskMonitorManager) {
        self.manager = manager
    }

    var folderDidChange: ((String) -> Void)? {
        get { manager.folderDidChange }
        set { manager.folderDidChange = newValue }
    }

    func startMonitoring(url: URL) {
        manager.startMonitoring(url: url)
    }

    func stopMonitoring() {
        manager.stopMonitoring()
    }
}
