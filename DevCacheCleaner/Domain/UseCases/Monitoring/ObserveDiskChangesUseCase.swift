//
//  ObserveDiskChangesUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

final class ObserveDiskChangesUseCase {

    private var diskMonitoringRepository: DiskMonitoringRepository

    init(diskMonitoringRepository: DiskMonitoringRepository) {
        self.diskMonitoringRepository = diskMonitoringRepository
    }

    func start(url: URL, onChange: @escaping (String) -> Void) {
        diskMonitoringRepository.folderDidChange = onChange
        diskMonitoringRepository.startMonitoring(url: url)
    }

    func stop() {
        diskMonitoringRepository.folderDidChange = nil
        diskMonitoringRepository.stopMonitoring()
    }
}
